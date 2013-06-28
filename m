Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 22FB56B0036
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 12:40:16 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id m6so1050434wiv.14
        for <linux-mm@kvack.org>; Fri, 28 Jun 2013 09:40:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130603174351.d04b2ac71d1bab0df242e0ba@mxc.nes.nec.co.jp>
References: <20130523052421.13864.83978.stgit@localhost6.localdomain6>
	<20130523052547.13864.83306.stgit@localhost6.localdomain6>
	<20130523152445.17549682ae45b5aab3f3cde0@linux-foundation.org>
	<CAJGZr0LwivLTH+E7WAR1B9_6B4e=jv04KgCUL_PdVpi9JjDpBw@mail.gmail.com>
	<51A2BBA7.50607@jp.fujitsu.com>
	<CAJGZr0LmsFXEgb3UXVb+rqo1aq5KJyNxyNAD+DG+3KnJm_ZncQ@mail.gmail.com>
	<51A71B49.3070003@cn.fujitsu.com>
	<CAJGZr0Ld6Q4a4f-VObAbvqCp=+fTFNEc6M-Fdnhh28GTcSm1=w@mail.gmail.com>
	<20130603174351.d04b2ac71d1bab0df242e0ba@mxc.nes.nec.co.jp>
Date: Fri, 28 Jun 2013 20:40:14 +0400
Message-ID: <CAJGZr0+9VUweN1Ssdq6P9Lug1GnTB3+RPv77JLRmnw=rpd9+Dw@mail.gmail.com>
Subject: Re: [PATCH v8 9/9] vmcore: support mmap() on /proc/vmcore
From: Maxim Uvarov <muvarov@gmail.com>
Content-Type: multipart/alternative; boundary=001a11c2228c7c2b0f04e03988d4
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>
Cc: riel@redhat.com, kexec@lists.infradead.org, hughd@google.com, linux-kernel@vger.kernel.org, lisa.mitchell@hp.com, vgoyal@redhat.com, linux-mm@kvack.org, d.hatayama@jp.fujitsu.com, zhangyanfei@cn.fujitsu.com, ebiederm@xmission.com, kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, walken@google.com, cpw@sgi.com, jingbai.ma@hp.com

--001a11c2228c7c2b0f04e03988d4
Content-Type: text/plain; charset=ISO-8859-1

Did test on 1TB machine. Total vmcore capture and save took 143 minutes
while vmcore size increased from 9Gb to 59Gb.

Will do some debug for that.

Maxim.

2013/6/3 Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>

> Hello Maxim,
>
> On Thu, 30 May 2013 14:30:01 +0400
> Maxim Uvarov <muvarov@gmail.com> wrote:
>
> > 2013/5/30 Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> >
> > > On 05/30/2013 05:14 PM, Maxim Uvarov wrote:
> > > >
> > > >
> > > >
> > > > 2013/5/27 HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com <mailto:
> > > d.hatayama@jp.fujitsu.com>>
> > > >
> > > >     (2013/05/24 18:02), Maxim Uvarov wrote:
> > > >
> > > >
> > > >
> > > >
> > > >         2013/5/24 Andrew Morton <akpm@linux-foundation.org <mailto:
> > > akpm@linux-foundation.org> <mailto:akpm@linux-foundation.__org
> <mailto:
> > > akpm@linux-foundation.org>>>
> > > >
> > > >
> > > >             On Thu, 23 May 2013 14:25:48 +0900 HATAYAMA Daisuke <
> > > d.hatayama@jp.fujitsu.com <mailto:d.hatayama@jp.fujitsu.com> <mailto:
> > > d.hatayama@jp.fujitsu.__com <mailto:d.hatayama@jp.fujitsu.com>>>
> wrote:
> > > >
> > > >              > This patch introduces mmap_vmcore().
> > > >              >
> > > >              > Don't permit writable nor executable mapping even with
> > > mprotect()
> > > >              > because this mmap() is aimed at reading crash dump
> memory.
> > > >              > Non-writable mapping is also requirement of
> > > remap_pfn_range() when
> > > >              > mapping linear pages on non-consecutive physical
> pages;
> > > see
> > > >              > is_cow_mapping().
> > > >              >
> > > >              > Set VM_MIXEDMAP flag to remap memory by
> remap_pfn_range
> > > and by
> > > >              > remap_vmalloc_range_pertial at the same time for a
> single
> > > >              > vma. do_munmap() can correctly clean partially
> remapped
> > > vma with two
> > > >              > functions in abnormal case. See zap_pte_range(),
> > > vm_normal_page() and
> > > >              > their comments for details.
> > > >              >
> > > >              > On x86-32 PAE kernels, mmap() supports at most 16TB
> > > memory only. This
> > > >              > limitation comes from the fact that the third
> argument of
> > > >              > remap_pfn_range(), pfn, is of 32-bit length on x86-32:
> > > unsigned long.
> > > >
> > > >             More reviewing and testing, please.
> > > >
> > > >
> > > >         Do you have git pull for both kernel and userland changes? I
> > > would like to do some more testing on my machines.
> > > >
> > > >         Maxim.
> > > >
> > > >
> > > >     Thanks! That's very helpful.
> > > >
> > > >     --
> > > >     Thanks.
> > > >     HATAYAMA, Daisuke
> > > >
> > > > Any update for this? Where can I checkout all sources?
> > >
> > > This series is now in Andrew Morton's -mm tree.
> > >
> > > Ok, and what about makedumpfile changes? Is it possible to fetch them
> from
> > somewhere?
>
> You can fetch them from here, "mmap" branch is the change:
>
>   git://git.code.sf.net/p/makedumpfile/code
>
> And they will be merged into v1.5.4.
>
>
> Thanks
> Atsushi Kumagai
>
> _______________________________________________
> kexec mailing list
> kexec@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/kexec
>



-- 
Best regards,
Maxim Uvarov

--001a11c2228c7c2b0f04e03988d4
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Did test on 1TB machine. Total vmcore capture and save took 143 minutes whi=
le vmcore size increased from 9Gb to 59Gb.<br><br>Will do some debug for th=
at.<br><br>Maxim.<br><br><div class=3D"gmail_quote">2013/6/3 Atsushi Kumaga=
i <span dir=3D"ltr">&lt;<a href=3D"mailto:kumagai-atsushi@mxc.nes.nec.co.jp=
" target=3D"_blank">kumagai-atsushi@mxc.nes.nec.co.jp</a>&gt;</span><br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">Hello Maxim,<br>
<div><div class=3D"h5"><br>
On Thu, 30 May 2013 14:30:01 +0400<br>
Maxim Uvarov &lt;<a href=3D"mailto:muvarov@gmail.com">muvarov@gmail.com</a>=
&gt; wrote:<br>
<br>
&gt; 2013/5/30 Zhang Yanfei &lt;<a href=3D"mailto:zhangyanfei@cn.fujitsu.co=
m">zhangyanfei@cn.fujitsu.com</a>&gt;<br>
&gt;<br>
&gt; &gt; On 05/30/2013 05:14 PM, Maxim Uvarov wrote:<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; 2013/5/27 HATAYAMA Daisuke &lt;<a href=3D"mailto:d.hatayama@=
jp.fujitsu.com">d.hatayama@jp.fujitsu.com</a> &lt;mailto:<br>
&gt; &gt; <a href=3D"mailto:d.hatayama@jp.fujitsu.com">d.hatayama@jp.fujits=
u.com</a>&gt;&gt;<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; =A0 =A0 (2013/05/24 18:02), Maxim Uvarov wrote:<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 2013/5/24 Andrew Morton &lt;<a href=3D"mailt=
o:akpm@linux-foundation.org">akpm@linux-foundation.org</a> &lt;mailto:<br>
&gt; &gt; <a href=3D"mailto:akpm@linux-foundation.org">akpm@linux-foundatio=
n.org</a>&gt; &lt;mailto:<a href=3D"mailto:akpm@linux-foundation.">akpm@lin=
ux-foundation.</a>__org &lt;mailto:<br>
&gt; &gt; <a href=3D"mailto:akpm@linux-foundation.org">akpm@linux-foundatio=
n.org</a>&gt;&gt;&gt;<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 On Thu, 23 May 2013 14:25:48 +0900 H=
ATAYAMA Daisuke &lt;<br>
&gt; &gt; <a href=3D"mailto:d.hatayama@jp.fujitsu.com">d.hatayama@jp.fujits=
u.com</a> &lt;mailto:<a href=3D"mailto:d.hatayama@jp.fujitsu.com">d.hatayam=
a@jp.fujitsu.com</a>&gt; &lt;mailto:<br>
&gt; &gt; d.hatayama@jp.fujitsu.__com &lt;mailto:<a href=3D"mailto:d.hataya=
ma@jp.fujitsu.com">d.hatayama@jp.fujitsu.com</a>&gt;&gt;&gt; wrote:<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; This patch introduces mmap_v=
mcore().<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt;<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; Don&#39;t permit writable no=
r executable mapping even with<br>
&gt; &gt; mprotect()<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; because this mmap() is aimed=
 at reading crash dump memory.<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; Non-writable mapping is also=
 requirement of<br>
&gt; &gt; remap_pfn_range() when<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; mapping linear pages on non-=
consecutive physical pages;<br>
&gt; &gt; see<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; is_cow_mapping().<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt;<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; Set VM_MIXEDMAP flag to rema=
p memory by remap_pfn_range<br>
&gt; &gt; and by<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; remap_vmalloc_range_pertial =
at the same time for a single<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; vma. do_munmap() can correct=
ly clean partially remapped<br>
&gt; &gt; vma with two<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; functions in abnormal case. =
See zap_pte_range(),<br>
&gt; &gt; vm_normal_page() and<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; their comments for details.<=
br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt;<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; On x86-32 PAE kernels, mmap(=
) supports at most 16TB<br>
&gt; &gt; memory only. This<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; limitation comes from the fa=
ct that the third argument of<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; remap_pfn_range(), pfn, is o=
f 32-bit length on x86-32:<br>
&gt; &gt; unsigned long.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 More reviewing and testing, please.<=
br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 Do you have git pull for both kernel and use=
rland changes? I<br>
&gt; &gt; would like to do some more testing on my machines.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 Maxim.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; =A0 =A0 Thanks! That&#39;s very helpful.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; =A0 =A0 --<br>
&gt; &gt; &gt; =A0 =A0 Thanks.<br>
&gt; &gt; &gt; =A0 =A0 HATAYAMA, Daisuke<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Any update for this? Where can I checkout all sources?<br>
&gt; &gt;<br>
&gt; &gt; This series is now in Andrew Morton&#39;s -mm tree.<br>
&gt; &gt;<br>
&gt; &gt; Ok, and what about makedumpfile changes? Is it possible to fetch =
them from<br>
&gt; somewhere?<br>
<br>
</div></div>You can fetch them from here, &quot;mmap&quot; branch is the ch=
ange:<br>
<br>
=A0 git://<a href=3D"http://git.code.sf.net/p/makedumpfile/code" target=3D"=
_blank">git.code.sf.net/p/makedumpfile/code</a><br>
<br>
And they will be merged into v1.5.4.<br>
<br>
<br>
Thanks<br>
<span class=3D"HOEnZb"><font color=3D"#888888">Atsushi Kumagai<br>
</font></span><div class=3D"HOEnZb"><div class=3D"h5"><br>
_______________________________________________<br>
kexec mailing list<br>
<a href=3D"mailto:kexec@lists.infradead.org">kexec@lists.infradead.org</a><=
br>
<a href=3D"http://lists.infradead.org/mailman/listinfo/kexec" target=3D"_bl=
ank">http://lists.infradead.org/mailman/listinfo/kexec</a><br>
</div></div></blockquote></div><br><br clear=3D"all"><br>-- <br>Best regard=
s,<br>Maxim Uvarov

--001a11c2228c7c2b0f04e03988d4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
