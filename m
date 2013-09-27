Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1D70B6B0032
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 04:08:09 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so2289623pdj.29
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 01:08:08 -0700 (PDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so2221890pbc.23
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 01:08:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130927062633.GB6726@gmail.com>
References: <5241D897.1090905@gmail.com>
	<5241DB62.2090300@gmail.com>
	<20130926145326.GH3482@htj.dyndns.org>
	<52446413.50504@gmail.com>
	<20130927062633.GB6726@gmail.com>
Date: Fri, 27 Sep 2013 16:08:06 +0800
Message-ID: <CANBD6kGStR-4dJRjoveNv7CtUu04gpsZZhBd=B6_=gMqrDZX6w@mail.gmail.com>
Subject: Re: [PATCH v5 6/6] mem-hotplug: Introduce movablenode boot option
From: Yanfei Zhang <zhangyanfei.yes@gmail.com>
Content-Type: multipart/alternative; boundary=047d7bb0500083f98004e758fc73
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, "lenb@kernel.org" <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "izumi.taku@jp.fujitsu.com" <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "vasilis.liaskovitis@profitbricks.com" <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "prarit@redhat.com" <prarit@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "imtangchen@gmail.com" <imtangchen@gmail.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

--047d7bb0500083f98004e758fc73
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

hello Ingo,

=E5=9C=A8 2013=E5=B9=B49=E6=9C=8827=E6=97=A5=E6=98=9F=E6=9C=9F=E4=BA=94=EF=
=BC=8CIngo Molnar =E5=86=99=E9=81=93=EF=BC=9A

>
> * Zhang Yanfei <zhangyanfei.yes@gmail.com <javascript:;>> wrote:
>
> > OK. Trying below:
> >
> > movablenode   [KNL,X86] This option enables the kernel to arrange
> >               hotpluggable memory into ZONE_MOVABLE zone. If memory
> >               in a node is all hotpluggable, the option may make
> >               the whole node has only one ZONE_MOVABLE zone, so that
> >               the whole node can be hot-removed after system is up.
> >               Note that this option may cause NUMA performance down.
>
> That paragraph doesn't really parse in several places ...


Sorry=E2=80=A6could you point out the places a bit?


>
> Also, more importantly, please explain why this needs to be a boot option=
.
> In terms of user friendliness boot options are at the bottom of the list,
> and boot options also don't really help feature tests.
>
> Presumably the feature is safe and has no costs, and hence could be added
> as a regular .config option, with a boot option only as an additional
> configurability option?


Yeah, the kernel already has config MOVABLE_NODE, which is the config
enabing this feature, and we introduce this boot option to expand the
configurability.

Thanks.
Zhang


>
> Thanks,
>
>         Ingo
>

--047d7bb0500083f98004e758fc73
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

hello Ingo,<br><br>=E5=9C=A8 2013=E5=B9=B49=E6=9C=8827=E6=97=A5=E6=98=9F=E6=
=9C=9F=E4=BA=94=EF=BC=8CIngo Molnar  =E5=86=99=E9=81=93=EF=BC=9A<br><blockq=
uote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc =
solid;padding-left:1ex"><br>
* Zhang Yanfei &lt;<a href=3D"javascript:;" onclick=3D"_e(event, &#39;cvml&=
#39;, &#39;zhangyanfei.yes@gmail.com&#39;)">zhangyanfei.yes@gmail.com</a>&g=
t; wrote:<br>
<br>
&gt; OK. Trying below:<br>
&gt;<br>
&gt; movablenode =C2=A0 [KNL,X86] This option enables the kernel to arrange=
<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 hotpluggable memory i=
nto ZONE_MOVABLE zone. If memory<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 in a node is all hotp=
luggable, the option may make<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 the whole node has on=
ly one ZONE_MOVABLE zone, so that<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 the whole node can be=
 hot-removed after system is up.<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Note that this option=
 may cause NUMA performance down.<br>
<br>
That paragraph doesn&#39;t really parse in several places ...</blockquote><=
div><br></div><div>Sorry=E2=80=A6could you point out the places a bit?</div=
><div>=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .=
8ex;border-left:1px #ccc solid;padding-left:1ex">

<br>
Also, more importantly, please explain why this needs to be a boot option.<=
br>
In terms of user friendliness boot options are at the bottom of the list,<b=
r>
and boot options also don&#39;t really help feature tests.<br>
<br>
Presumably the feature is safe and has no costs, and hence could be added<b=
r>
as a regular .config option, with a boot option only as an additional<br>
configurability option?</blockquote><div><br></div><div>Yeah, the kernel al=
ready has config MOVABLE_NODE, which is the config enabing this feature, an=
d we introduce this boot option to expand the configurability.</div><div>
<br></div><div>Thanks.</div><div>Zhang<span></span></div><div>=C2=A0</div><=
blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px=
 #ccc solid;padding-left:1ex">
<br>
Thanks,<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 Ingo<br>
</blockquote>

--047d7bb0500083f98004e758fc73--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
