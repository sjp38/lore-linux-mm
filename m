Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 62D5B8D0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 23:23:48 -0500 (EST)
Received: by mail-da0-f45.google.com with SMTP id w4so4593792dam.18
        for <linux-mm@kvack.org>; Thu, 27 Dec 2012 20:23:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50DC580C.7080507@samsung.com>
References: <1356592458-11077-1-git-send-email-prathyush.k@samsung.com>
	<50DC580C.7080507@samsung.com>
Date: Fri, 28 Dec 2012 09:53:47 +0530
Message-ID: <CAH=HWYP5r18qjQSc_2121vikbTMpYv6DKOfW=hpOpGB7rUyNRA@mail.gmail.com>
Subject: Re: [PATCH] arm: dma mapping: export arm iommu functions
From: Prathyush K <prathyush@chromium.org>
Content-Type: multipart/alternative; boundary=f46d042dff519c652c04d1e20725
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Prathyush K <prathyush.k@samsung.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org

--f46d042dff519c652c04d1e20725
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Dec 27, 2012 at 7:45 PM, Marek Szyprowski
<m.szyprowski@samsung.com>wrote:

> Hello,
>
>
> On 12/27/2012 8:14 AM, Prathyush K wrote:
>
>> This patch adds EXPORT_SYMBOL calls to the three arm iommu
>> functions - arm_iommu_create_mapping, arm_iommu_free_mapping
>> and arm_iommu_attach_device. These functions can now be called
>> from dynamic modules.
>>
>
> Could You describe a bit more why those functions might be needed by
> dynamic modules?
>
> Hi Marek,

We are adding iommu support to exynos gsc and s5p-mfc.
And these two drivers need to be built as modules to improve boot time.

We're calling these three functions from inside these drivers:
e.g.
mapping = arm_iommu_create_mapping(&platform_bus_type, 0x20000000, SZ_256M,
4);
arm_iommu_attach_device(mdev, mapping);



>
>  Signed-off-by: Prathyush K <prathyush.k@samsung.com>
>> ---
>>   arch/arm/mm/dma-mapping.c | 3 +++
>>   1 file changed, 3 insertions(+)
>>
>> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
>> index 6b2fb87..c0f0f43 100644
>> --- a/arch/arm/mm/dma-mapping.c
>> +++ b/arch/arm/mm/dma-mapping.c
>> @@ -1797,6 +1797,7 @@ err2:
>>   err:
>>         return ERR_PTR(err);
>>   }
>> +EXPORT_SYMBOL(arm_iommu_**create_mapping);
>>
>
> EXPORT_SYMOBL_GPL() ?
>
>
Right, it should be EXPORT_SYMOBL_GPL().

Will update in next patch.



>
>    static void release_iommu_mapping(struct kref *kref)
>>   {
>> @@ -1813,6 +1814,7 @@ void arm_iommu_release_mapping(**struct
>> dma_iommu_mapping *mapping)
>>         if (mapping)
>>                 kref_put(&mapping->kref, release_iommu_mapping);
>>   }
>> +EXPORT_SYMBOL(arm_iommu_**release_mapping);
>>     /**
>>    * arm_iommu_attach_device
>> @@ -1841,5 +1843,6 @@ int arm_iommu_attach_device(struct device *dev,
>>         pr_debug("Attached IOMMU controller to %s device.\n",
>> dev_name(dev));
>>         return 0;
>>   }
>> +EXPORT_SYMBOL(arm_iommu_**attach_device);
>>     #endif
>>
>
> Best regards
> --
> Marek Szyprowski
> Samsung Poland R&D Center
>
>
> Regards,
Prathyush

--f46d042dff519c652c04d1e20725
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><br><div class=3D"gmail=
_quote">On Thu, Dec 27, 2012 at 7:45 PM, Marek Szyprowski <span dir=3D"ltr"=
>&lt;<a href=3D"mailto:m.szyprowski@samsung.com" target=3D"_blank">m.szypro=
wski@samsung.com</a>&gt;</span> wrote:<br>

<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;p=
adding-left:1ex">Hello,<div><br>
<br>
On 12/27/2012 8:14 AM, Prathyush K wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;p=
adding-left:1ex">
This patch adds EXPORT_SYMBOL calls to the three arm iommu<br>
functions - arm_iommu_create_mapping, arm_iommu_free_mapping<br>
and arm_iommu_attach_device. These functions can now be called<br>
from dynamic modules.<br>
</blockquote>
<br></div>
Could You describe a bit more why those functions might be needed by dynami=
c modules?<div><br></div></blockquote><div>Hi Marek,</div><div><br></div><d=
iv>We are adding iommu support to exynos gsc and s5p-mfc.</div><div style>
And these two drivers need to be built as modules to improve boot time.</di=
v><div style><br></div><div style>We&#39;re calling these three functions f=
rom inside these drivers:</div><div style><div style>e.g.</div><div>mapping=
 =3D arm_iommu_create_mapping(&amp;platform_bus_type, 0x20000000,=A0SZ_256M=
, 4);</div>
<div>arm_iommu_attach_device(mdev, mapping);<br></div></div>
<div><br></div><div style>=A0<br></div><blockquote class=3D"gmail_quote" st=
yle=3D"margin:0px 0px 0px 0.8ex;border-left-width:1px;border-left-color:rgb=
(204,204,204);border-left-style:solid;padding-left:1ex"><div>
<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;p=
adding-left:1ex">
Signed-off-by: Prathyush K &lt;<a href=3D"mailto:prathyush.k@samsung.com" t=
arget=3D"_blank">prathyush.k@samsung.com</a>&gt;<br>
---<br>
=A0 arch/arm/mm/dma-mapping.c | 3 +++<br>
=A0 1 file changed, 3 insertions(+)<br>
<br>
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c<br>
index 6b2fb87..c0f0f43 100644<br>
--- a/arch/arm/mm/dma-mapping.c<br>
+++ b/arch/arm/mm/dma-mapping.c<br>
@@ -1797,6 +1797,7 @@ err2:<br>
=A0 err:<br>
=A0 =A0 =A0 =A0 return ERR_PTR(err);<br>
=A0 }<br>
+EXPORT_SYMBOL(arm_iommu_<u></u>create_mapping);<br>
</blockquote>
<br></div>
EXPORT_SYMOBL_GPL() ?<div><br></div></blockquote><div><br></div><div style>=
Right, it should be=A0EXPORT_SYMOBL_GPL().</div><div style><br></div><div s=
tyle>Will update in next patch.</div><div><br></div><div>=A0</div><blockquo=
te class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left-widt=
h:1px;border-left-color:rgb(204,204,204);border-left-style:solid;padding-le=
ft:1ex">
<div>
<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;p=
adding-left:1ex">
=A0 static void release_iommu_mapping(struct kref *kref)<br>
=A0 {<br>
@@ -1813,6 +1814,7 @@ void arm_iommu_release_mapping(<u></u>struct dma_iomm=
u_mapping *mapping)<br>
=A0 =A0 =A0 =A0 if (mapping)<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kref_put(&amp;mapping-&gt;kref, release_iom=
mu_mapping);<br>
=A0 }<br>
+EXPORT_SYMBOL(arm_iommu_<u></u>release_mapping);<br>
=A0 =A0 /**<br>
=A0 =A0* arm_iommu_attach_device<br>
@@ -1841,5 +1843,6 @@ int arm_iommu_attach_device(struct device *dev,<br>
=A0 =A0 =A0 =A0 pr_debug(&quot;Attached IOMMU controller to %s device.\n&qu=
ot;, dev_name(dev));<br>
=A0 =A0 =A0 =A0 return 0;<br>
=A0 }<br>
+EXPORT_SYMBOL(arm_iommu_<u></u>attach_device);<br>
=A0 =A0 #endif<br>
</blockquote>
<br></div>
Best regards<span><font color=3D"#888888"><br>
-- <br>
Marek Szyprowski<br>
Samsung Poland R&amp;D Center<br>
<br>
<br>
</font></span></blockquote></div>Regards,</div><div class=3D"gmail_extra" s=
tyle>Prathyush</div><div class=3D"gmail_extra"><br></div><div class=3D"gmai=
l_extra"><br></div><div class=3D"gmail_extra"><br></div></div>

--f46d042dff519c652c04d1e20725--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
