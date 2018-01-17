Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0928A280263
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 20:59:51 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id n10so3887949otb.2
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 17:59:51 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u37sor1475116otf.202.2018.01.16.17.59.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jan 2018 17:59:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <97e9fc59-0fc9-2c53-2713-6195f0375afe@huawei.com>
References: <20180116213008.GC8801@redhat.com> <97e9fc59-0fc9-2c53-2713-6195f0375afe@huawei.com>
From: "Figo.zhang" <figo1802@gmail.com>
Date: Wed, 17 Jan 2018 09:59:49 +0800
Message-ID: <CAF7GXvpKn2xH23Q61gorGMAwPzKpo-p441pa1GS=_sQ1KxD52w@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] HMM status upstream user what's next, mmu_notifier
Content-Type: multipart/alternative; boundary="001a113d1a1cd84b440562ef3324"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liubo(OS Lab)" <liubo95@huawei.com>
Cc: Jerome Glisse <jglisse@redhat.com>, lsf-pc@lists.linux-foundation.org, Linux MM <linux-mm@kvack.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, David Rientjes <rientjes@google.com>, John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>

--001a113d1a1cd84b440562ef3324
Content-Type: text/plain; charset="UTF-8"

2018-01-17 9:19 GMT+08:00 Liubo(OS Lab) <liubo95@huawei.com>:

> On 2018/1/17 5:30, Jerome Glisse wrote:
> > I want to talk about status of HMM and respective upstream user for
> > it and also talk about what's next in term of features/improvement
> > plan (generic page write protection, mmu_notifier, ...). Most likely
>
> I don't think we should consider to push more code to upstream for a
> nobody-use feature.
>
> AFAIR, Michal also mentioned that HMM need a real user/driver before
> upstream.
> But I haven't seen a workable user/driver version.
>
> Looks like HMM is a custom framework for Nvidia, and Nvidia would not like
> to open source its driver.
> Even if nvidia really use HMM and open sourced its driver, it's probably
> the only user.
> But the HMM framework touched too much core mm code.
>

HMM looks suitable for FPGA user case, FPGA and CPU need coherency. ~_~


>
> Cheers,
> Liubo
>
> > short 15-30minutes if mmu_notifier is split into its own topic.
> >
> > I want to talk about mmu_notifier, specificaly adding more context
> > information to mmu_notifier callback (why a notification is happening
> > reclaim, munmap, migrate, ...). Maybe we can grow this into its own
> > topic and talk about mmu_notifier and issue with it like OOM or being
> > able to sleep/take lock ... and improving mitigation.
> >
> > People (mmu_notifier probably interest a larger set):
> >     "Anshuman Khandual" <khandual@linux.vnet.ibm.com>
> >     "Balbir Singh" <bsingharora@gmail.com>
> >     "David Rientjes" <rientjes@google.com>
> >     "John Hubbard" <jhubbard@nvidia.com>
> >     "Michal Hocko" <mhocko@suse.com>
> >
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--001a113d1a1cd84b440562ef3324
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">2018-01-17 9:19 GMT+08:00 Liubo(OS Lab) <span dir=3D"ltr">&lt;<a href=
=3D"mailto:liubo95@huawei.com" target=3D"_blank">liubo95@huawei.com</a>&gt;=
</span>:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;bo=
rder-left:1px #ccc solid;padding-left:1ex"><span class=3D"">On 2018/1/17 5:=
30, Jerome Glisse wrote:<br>
&gt; I want to talk about status of HMM and respective upstream user for<br=
>
&gt; it and also talk about what&#39;s next in term of features/improvement=
<br>
&gt; plan (generic page write protection, mmu_notifier, ...). Most likely<b=
r>
<br>
</span>I don&#39;t think we should consider to push more code to upstream f=
or a nobody-use feature.<br>
<br>
AFAIR, Michal also mentioned that HMM need a real user/driver before upstre=
am.<br>
But I haven&#39;t seen a workable user/driver version.<br>
<br>
Looks like HMM is a custom framework for Nvidia, and Nvidia would not like =
to open source its driver.<br>
Even if nvidia really use HMM and open sourced its driver, it&#39;s probabl=
y the only user.<br>
But the HMM framework touched too much core mm code.<br></blockquote><div>=
=C2=A0</div><div>HMM=C2=A0looks suitable=C2=A0for FPGA=C2=A0user case, FPGA=
 and CPU need coherency. ~_~</div><div>=C2=A0</div><blockquote class=3D"gma=
il_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-lef=
t:1ex">
<br>
Cheers,<br>
Liubo<br>
<div class=3D"HOEnZb"><div class=3D"h5"><br>
&gt; short 15-30minutes if mmu_notifier is split into its own topic.<br>
&gt;<br>
&gt; I want to talk about mmu_notifier, specificaly adding more context<br>
&gt; information to mmu_notifier callback (why a notification is happening<=
br>
&gt; reclaim, munmap, migrate, ...). Maybe we can grow this into its own<br=
>
&gt; topic and talk about mmu_notifier and issue with it like OOM or being<=
br>
&gt; able to sleep/take lock ... and improving mitigation.<br>
&gt;<br>
&gt; People (mmu_notifier probably interest a larger set):<br>
&gt;=C2=A0 =C2=A0 =C2=A0&quot;Anshuman Khandual&quot; &lt;<a href=3D"mailto=
:khandual@linux.vnet.ibm.com">khandual@linux.vnet.ibm.com</a>&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0&quot;Balbir Singh&quot; &lt;<a href=3D"mailto:bsin=
gharora@gmail.com">bsingharora@gmail.com</a>&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0&quot;David Rientjes&quot; &lt;<a href=3D"mailto:ri=
entjes@google.com">rientjes@google.com</a>&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0&quot;John Hubbard&quot; &lt;<a href=3D"mailto:jhub=
bard@nvidia.com">jhubbard@nvidia.com</a>&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0&quot;Michal Hocko&quot; &lt;<a href=3D"mailto:mhoc=
ko@suse.com">mhocko@suse.com</a>&gt;<br>
&gt;<br>
<br>
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
</div></div></blockquote></div><br></div></div>

--001a113d1a1cd84b440562ef3324--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
