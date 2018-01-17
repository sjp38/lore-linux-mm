Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 28C12280263
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 20:55:16 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id 95so2176132otl.16
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 17:55:16 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c188sor1145136oih.200.2018.01.16.17.55.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jan 2018 17:55:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180116210321.GB8801@redhat.com>
References: <20180116210321.GB8801@redhat.com>
From: "Figo.zhang" <figo1802@gmail.com>
Date: Wed, 17 Jan 2018 09:55:14 +0800
Message-ID: <CAF7GXvpsAPhHWFV3g9LdzKg6Fe=Csp+kecG+HznoaT0Hiu9HCw@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] CAPI/CCIX cache coherent device memory (NUMA too ?)
Content-Type: multipart/alternative; boundary="001a113da306716d330562ef2364"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, Linux MM <linux-mm@kvack.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <jhubbard@nvidia.com>, Jonathan Masters <jcm@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

--001a113da306716d330562ef2364
Content-Type: text/plain; charset="UTF-8"

2018-01-17 5:03 GMT+08:00 Jerome Glisse <jglisse@redhat.com>:

> CAPI (on IBM Power8 and 9) and CCIX are two new standard that
> build on top of existing interconnect (like PCIE) and add the
> possibility for cache coherent access both way (from CPU to
> device memory and from device to main memory). This extend
> what we are use to with PCIE (where only device to main memory
> can be cache coherent but not CPU to device memory).
>

the UPI bus also support cache coherency for Intel platform, right?
it seem the specification of CCIX/CAPI protocol is not public, we cannot
know the details
about them, your topic will cover the details?


>
> How is this memory gonna be expose to the kernel and how the
> kernel gonna expose this to user space is the topic i want to
> discuss. I believe this is highly device specific for instance
> for GPU you want the device memory allocation and usage to be
> under the control of the GPU device driver. Maybe other type
> of device want different strategy.
>
i see it lack of some simple example for how to use the
HMM, because GPU driver is more
complicate for linux driver developer  except the ATI/NVIDIA developers.

>
> The HMAT patchset is partialy related to all this as it is about
> exposing different type of memory available in a system for CPU
> (HBM, main memory, ...) and some of their properties (bandwidth,
> latency, ...).
>
>
> We can start by looking at how CAPI and CCIX plan to expose this
> to the kernel and try to list some of the type of devices we
> expect to see. Discussion can then happen on how to represent this
> internaly to the kernel and how to expose this to userspace.
>
> Note this might also trigger discussion on a NUMA like model or
> on extending/replacing it by something more generic.
>
>
> Peoples (alphabetical order on first name) sorry if i missed
> anyone:
>     "Anshuman Khandual" <khandual@linux.vnet.ibm.com>
>     "Balbir Singh" <bsingharora@gmail.com>
>     "Dan Williams" <dan.j.williams@intel.com>
>     "John Hubbard" <jhubbard@nvidia.com>
>     "Jonathan Masters" <jcm@redhat.com>
>     "Ross Zwisler" <ross.zwisler@linux.intel.com>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--001a113da306716d330562ef2364
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">=
2018-01-17 5:03 GMT+08:00 Jerome Glisse <span dir=3D"ltr">&lt;<a href=3D"ma=
ilto:jglisse@redhat.com" target=3D"_blank">jglisse@redhat.com</a>&gt;</span=
>:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-l=
eft:1px #ccc solid;padding-left:1ex">CAPI (on IBM Power8 and 9) and CCIX ar=
e two new standard that<br>
build on top of existing interconnect (like PCIE) and add the<br>
possibility for cache coherent access both way (from CPU to<br>
device memory and from device to main memory). This extend<br>
what we are use to with PCIE (where only device to main memory<br>
can be cache coherent but not CPU to device memory).<br></blockquote><div><=
br></div><div>the UPI bus=C2=A0also=C2=A0support=C2=A0cache=C2=A0coherency =
for Intel=C2=A0platform,=C2=A0right?</div><div>it=C2=A0seem the specificati=
on=C2=A0of CCIX/CAPI protocol is not=C2=A0public, we cannot know the=C2=A0d=
etails</div><div>about=C2=A0them, your topic will=C2=A0cover the=C2=A0detai=
ls?</div><div>=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"margin=
:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<br>
How is this memory gonna be expose to the kernel and how the<br>
kernel gonna expose this to user space is the topic i want to<br>
discuss. I believe this is highly device specific for instance<br>
for GPU you want the device memory allocation and usage to be<br>
under the control of the GPU device driver. Maybe other type<br>
of device want different strategy.<br></blockquote><div>i see it lack of=C2=
=A0some=C2=A0simple=C2=A0example for how to use the HMM,=C2=A0because=C2=A0=
GPU=C2=A0driver=C2=A0is=C2=A0more</div><div>complicate=C2=A0for=C2=A0linux=
=C2=A0driver developer=C2=A0 except the ATI/NVIDIA developers.</div><blockq=
uote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc =
solid;padding-left:1ex">
<br>
The HMAT patchset is partialy related to all this as it is about<br>
exposing different type of memory available in a system for CPU<br>
(HBM, main memory, ...) and some of their properties (bandwidth,<br>
latency, ...).<br>
<br>
<br>
We can start by looking at how CAPI and CCIX plan to expose this<br>
to the kernel and try to list some of the type of devices we<br>
expect to see. Discussion can then happen on how to represent this<br>
internaly to the kernel and how to expose this to userspace.<br>
<br>
Note this might also trigger discussion on a NUMA like model or<br>
on extending/replacing it by something more generic.<br>
<br>
<br>
Peoples (alphabetical order on first name) sorry if i missed<br>
anyone:<br>
=C2=A0 =C2=A0 &quot;Anshuman Khandual&quot; &lt;<a href=3D"mailto:khandual@=
linux.vnet.ibm.com">khandual@linux.vnet.ibm.com</a>&gt;<br>
=C2=A0 =C2=A0 &quot;Balbir Singh&quot; &lt;<a href=3D"mailto:bsingharora@gm=
ail.com">bsingharora@gmail.com</a>&gt;<br>
=C2=A0 =C2=A0 &quot;Dan Williams&quot; &lt;<a href=3D"mailto:dan.j.williams=
@intel.com">dan.j.williams@intel.com</a>&gt;<br>
=C2=A0 =C2=A0 &quot;John Hubbard&quot; &lt;<a href=3D"mailto:jhubbard@nvidi=
a.com">jhubbard@nvidia.com</a>&gt;<br>
=C2=A0 =C2=A0 &quot;Jonathan Masters&quot; &lt;<a href=3D"mailto:jcm@redhat=
.com">jcm@redhat.com</a>&gt;<br>
=C2=A0 =C2=A0 &quot;Ross Zwisler&quot; &lt;<a href=3D"mailto:ross.zwisler@l=
inux.intel.com">ross.zwisler@linux.intel.com</a>&gt;<br>
<br>
--<br>
To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org</a>.=
=C2=A0 For more info on Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" rel=3D"noreferrer" target=3D"_bla=
nk">http://www.linux-mm.org/</a> .<br>
Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvack.org=
">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">email@kva=
ck.org</a> &lt;/a&gt;<br>
</blockquote></div><br></div></div>

--001a113da306716d330562ef2364--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
