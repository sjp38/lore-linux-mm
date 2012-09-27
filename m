Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 1F1F86B0044
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 06:20:15 -0400 (EDT)
Received: by qadc11 with SMTP id c11so2172737qad.14
        for <linux-mm@kvack.org>; Thu, 27 Sep 2012 03:20:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1348724705-23779-2-git-send-email-wency@cn.fujitsu.com>
References: <1348724705-23779-1-git-send-email-wency@cn.fujitsu.com>
	<1348724705-23779-2-git-send-email-wency@cn.fujitsu.com>
Date: Thu, 27 Sep 2012 18:20:13 +0800
Message-ID: <CAEkdkmVW5wwG4_cy0yHFNVmk2bzAqzo2adRsMn1yHOW9Ex98_g@mail.gmail.com>
Subject: Re: [PATCH 1/4] memory-hotplug: add memory_block_release
From: Ni zhan Chen <nizhan.chen@gmail.com>
Content-Type: multipart/alternative; boundary=20cf300fae61f28a9304caac48e5
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wency@cn.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com

--20cf300fae61f28a9304caac48e5
Content-Type: text/plain; charset=ISO-8859-1

Hi Congyang,

2012/9/27 <wency@cn.fujitsu.com>

> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>
> When calling remove_memory_block(), the function shows following message at
> device_release().
>
> Device 'memory528' does not have a release() function, it is broken and
> must
> be fixed.
>

What's the difference between the patch and original implemetation?


> remove_memory_block() calls kfree(mem). I think it shouled be called from
> device_release(). So the patch implements memory_block_release()
>
> CC: David Rientjes <rientjes@google.com>
> CC: Jiang Liu <liuj97@gmail.com>
> CC: Len Brown <len.brown@intel.com>
> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> CC: Paul Mackerras <paulus@samba.org>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Wen Congyang <wency@cn.fujitsu.com>
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> ---
>  drivers/base/memory.c |    9 ++++++++-
>  1 files changed, 8 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 7dda4f7..da457e5 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -70,6 +70,13 @@ void unregister_memory_isolate_notifier(struct
> notifier_block *nb)
>  }
>  EXPORT_SYMBOL(unregister_memory_isolate_notifier);
>
> +static void release_memory_block(struct device *dev)
> +{
> +       struct memory_block *mem = container_of(dev, struct memory_block,
> dev);
> +
> +       kfree(mem);
> +}
> +
>  /*
>   * register_memory - Setup a sysfs device for a memory block
>   */
> @@ -80,6 +87,7 @@ int register_memory(struct memory_block *memory)
>
>         memory->dev.bus = &memory_subsys;
>         memory->dev.id = memory->start_section_nr / sections_per_block;
> +       memory->dev.release = release_memory_block;
>
>         error = device_register(&memory->dev);
>         return error;
> @@ -630,7 +638,6 @@ int remove_memory_block(unsigned long node_id, struct
> mem_section *section,
>                 mem_remove_simple_file(mem, phys_device);
>                 mem_remove_simple_file(mem, removable);
>                 unregister_memory(mem);
> -               kfree(mem);
>         } else
>                 kobject_put(&mem->dev.kobj);
>
> --
> 1.7.1
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--20cf300fae61f28a9304caac48e5
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi=A0Congyang,<br><br><div class=3D"gmail_quote">2012/9/27  <span dir=3D"lt=
r">&lt;<a href=3D"mailto:wency@cn.fujitsu.com" target=3D"_blank">wency@cn.f=
ujitsu.com</a>&gt;</span><br><blockquote class=3D"gmail_quote" style=3D"mar=
gin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
From: Yasuaki Ishimatsu &lt;<a href=3D"mailto:isimatu.yasuaki@jp.fujitsu.co=
m">isimatu.yasuaki@jp.fujitsu.com</a>&gt;<br>
<br>
When calling remove_memory_block(), the function shows following message at=
<br>
device_release().<br>
<br>
Device &#39;memory528&#39; does not have a release() function, it is broken=
 and must<br>
be fixed.<br></blockquote><div><br></div><div>What&#39;s the difference bet=
ween the patch and original implemetation? =A0</div><div><br></div><blockqu=
ote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc s=
olid;padding-left:1ex">

<br>
remove_memory_block() calls kfree(mem). I think it shouled be called from<b=
r>
device_release(). So the patch implements memory_block_release()<br>
<br>
CC: David Rientjes &lt;<a href=3D"mailto:rientjes@google.com">rientjes@goog=
le.com</a>&gt;<br>
CC: Jiang Liu &lt;<a href=3D"mailto:liuj97@gmail.com">liuj97@gmail.com</a>&=
gt;<br>
CC: Len Brown &lt;<a href=3D"mailto:len.brown@intel.com">len.brown@intel.co=
m</a>&gt;<br>
CC: Benjamin Herrenschmidt &lt;<a href=3D"mailto:benh@kernel.crashing.org">=
benh@kernel.crashing.org</a>&gt;<br>
CC: Paul Mackerras &lt;<a href=3D"mailto:paulus@samba.org">paulus@samba.org=
</a>&gt;<br>
Cc: Minchan Kim &lt;<a href=3D"mailto:minchan.kim@gmail.com">minchan.kim@gm=
ail.com</a>&gt;<br>
CC: Andrew Morton &lt;<a href=3D"mailto:akpm@linux-foundation.org">akpm@lin=
ux-foundation.org</a>&gt;<br>
CC: KOSAKI Motohiro &lt;<a href=3D"mailto:kosaki.motohiro@jp.fujitsu.com">k=
osaki.motohiro@jp.fujitsu.com</a>&gt;<br>
CC: Wen Congyang &lt;<a href=3D"mailto:wency@cn.fujitsu.com">wency@cn.fujit=
su.com</a>&gt;<br>
Signed-off-by: Yasuaki Ishimatsu &lt;<a href=3D"mailto:isimatu.yasuaki@jp.f=
ujitsu.com">isimatu.yasuaki@jp.fujitsu.com</a>&gt;<br>
---<br>
=A0drivers/base/memory.c | =A0 =A09 ++++++++-<br>
=A01 files changed, 8 insertions(+), 1 deletions(-)<br>
<br>
diff --git a/drivers/base/memory.c b/drivers/base/memory.c<br>
index 7dda4f7..da457e5 100644<br>
--- a/drivers/base/memory.c<br>
+++ b/drivers/base/memory.c<br>
@@ -70,6 +70,13 @@ void unregister_memory_isolate_notifier(struct notifier_=
block *nb)<br>
=A0}<br>
=A0EXPORT_SYMBOL(unregister_memory_isolate_notifier);<br>
<br>
+static void release_memory_block(struct device *dev)<br>
+{<br>
+ =A0 =A0 =A0 struct memory_block *mem =3D container_of(dev, struct memory_=
block, dev);<br>
+<br>
+ =A0 =A0 =A0 kfree(mem);<br>
+}<br>
+<br>
=A0/*<br>
=A0 * register_memory - Setup a sysfs device for a memory block<br>
=A0 */<br>
@@ -80,6 +87,7 @@ int register_memory(struct memory_block *memory)<br>
<br>
=A0 =A0 =A0 =A0 memory-&gt;dev.bus =3D &amp;memory_subsys;<br>
=A0 =A0 =A0 =A0 memory-&gt;<a href=3D"http://dev.id" target=3D"_blank">dev.=
id</a> =3D memory-&gt;start_section_nr / sections_per_block;<br>
+ =A0 =A0 =A0 memory-&gt;dev.release =3D release_memory_block;<br>
<br>
=A0 =A0 =A0 =A0 error =3D device_register(&amp;memory-&gt;dev);<br>
=A0 =A0 =A0 =A0 return error;<br>
@@ -630,7 +638,6 @@ int remove_memory_block(unsigned long node_id, struct m=
em_section *section,<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_remove_simple_file(mem, phys_device);<b=
r>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_remove_simple_file(mem, removable);<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unregister_memory(mem);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(mem);<br>
=A0 =A0 =A0 =A0 } else<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kobject_put(&amp;mem-&gt;dev.kobj);<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
--<br>
1.7.1<br>
<br>
--<br>
To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org</a>.=
 =A0For more info on Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www.linu=
x-mm.org/</a> .<br>
Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvack.org=
">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">email@kva=
ck.org</a> &lt;/a&gt;<br>
</font></span></blockquote></div><br>

--20cf300fae61f28a9304caac48e5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
