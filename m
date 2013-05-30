Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id F32466B0032
	for <linux-mm@kvack.org>; Thu, 30 May 2013 06:30:02 -0400 (EDT)
Received: by mail-ob0-f172.google.com with SMTP id wo10so147522obc.17
        for <linux-mm@kvack.org>; Thu, 30 May 2013 03:30:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <51A71B49.3070003@cn.fujitsu.com>
References: <20130523052421.13864.83978.stgit@localhost6.localdomain6>
	<20130523052547.13864.83306.stgit@localhost6.localdomain6>
	<20130523152445.17549682ae45b5aab3f3cde0@linux-foundation.org>
	<CAJGZr0LwivLTH+E7WAR1B9_6B4e=jv04KgCUL_PdVpi9JjDpBw@mail.gmail.com>
	<51A2BBA7.50607@jp.fujitsu.com>
	<CAJGZr0LmsFXEgb3UXVb+rqo1aq5KJyNxyNAD+DG+3KnJm_ZncQ@mail.gmail.com>
	<51A71B49.3070003@cn.fujitsu.com>
Date: Thu, 30 May 2013 14:30:01 +0400
Message-ID: <CAJGZr0Ld6Q4a4f-VObAbvqCp=+fTFNEc6M-Fdnhh28GTcSm1=w@mail.gmail.com>
Subject: Re: [PATCH v8 9/9] vmcore: support mmap() on /proc/vmcore
From: Maxim Uvarov <muvarov@gmail.com>
Content-Type: multipart/alternative; boundary=001a11c2fbd0208b6404ddecfb4e
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, hughd@google.com, jingbai.ma@hp.com, "kexec@lists.infradead.org" <kexec@lists.infradead.org>, linux-kernel@vger.kernel.org, lisa.mitchell@hp.com, linux-mm@kvack.org, Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>, "Eric W. Biederman" <ebiederm@xmission.com>, kosaki.motohiro@jp.fujitsu.com, walken@google.com, Cliff Wickman <cpw@sgi.com>, Vivek Goyal <vgoyal@redhat.com>

--001a11c2fbd0208b6404ddecfb4e
Content-Type: text/plain; charset=ISO-8859-1

2013/5/30 Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

> On 05/30/2013 05:14 PM, Maxim Uvarov wrote:
> >
> >
> >
> > 2013/5/27 HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com <mailto:
> d.hatayama@jp.fujitsu.com>>
> >
> >     (2013/05/24 18:02), Maxim Uvarov wrote:
> >
> >
> >
> >
> >         2013/5/24 Andrew Morton <akpm@linux-foundation.org <mailto:
> akpm@linux-foundation.org> <mailto:akpm@linux-foundation.__org <mailto:
> akpm@linux-foundation.org>>>
> >
> >
> >             On Thu, 23 May 2013 14:25:48 +0900 HATAYAMA Daisuke <
> d.hatayama@jp.fujitsu.com <mailto:d.hatayama@jp.fujitsu.com> <mailto:
> d.hatayama@jp.fujitsu.__com <mailto:d.hatayama@jp.fujitsu.com>>> wrote:
> >
> >              > This patch introduces mmap_vmcore().
> >              >
> >              > Don't permit writable nor executable mapping even with
> mprotect()
> >              > because this mmap() is aimed at reading crash dump memory.
> >              > Non-writable mapping is also requirement of
> remap_pfn_range() when
> >              > mapping linear pages on non-consecutive physical pages;
> see
> >              > is_cow_mapping().
> >              >
> >              > Set VM_MIXEDMAP flag to remap memory by remap_pfn_range
> and by
> >              > remap_vmalloc_range_pertial at the same time for a single
> >              > vma. do_munmap() can correctly clean partially remapped
> vma with two
> >              > functions in abnormal case. See zap_pte_range(),
> vm_normal_page() and
> >              > their comments for details.
> >              >
> >              > On x86-32 PAE kernels, mmap() supports at most 16TB
> memory only. This
> >              > limitation comes from the fact that the third argument of
> >              > remap_pfn_range(), pfn, is of 32-bit length on x86-32:
> unsigned long.
> >
> >             More reviewing and testing, please.
> >
> >
> >         Do you have git pull for both kernel and userland changes? I
> would like to do some more testing on my machines.
> >
> >         Maxim.
> >
> >
> >     Thanks! That's very helpful.
> >
> >     --
> >     Thanks.
> >     HATAYAMA, Daisuke
> >
> > Any update for this? Where can I checkout all sources?
>
> This series is now in Andrew Morton's -mm tree.
>
> Ok, and what about makedumpfile changes? Is it possible to fetch them from
somewhere?


> --
> Thanks.
> Zhang Yanfei
>



-- 
Best regards,
Maxim Uvarov

--001a11c2fbd0208b6404ddecfb4e
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><br><div class=3D"gmail=
_quote">2013/5/30 Zhang Yanfei <span dir=3D"ltr">&lt;<a href=3D"mailto:zhan=
gyanfei@cn.fujitsu.com" target=3D"_blank">zhangyanfei@cn.fujitsu.com</a>&gt=
;</span><br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">On 05/30/2013 05:14 PM, Maxim Uvarov wrote:<=
br>
&gt;<br>
&gt;<br>
&gt;<br>
&gt; 2013/5/27 HATAYAMA Daisuke &lt;<a href=3D"mailto:d.hatayama@jp.fujitsu=
.com">d.hatayama@jp.fujitsu.com</a> &lt;mailto:<a href=3D"mailto:d.hatayama=
@jp.fujitsu.com">d.hatayama@jp.fujitsu.com</a>&gt;&gt;<br>
<div class=3D"im">&gt;<br>
&gt; =A0 =A0 (2013/05/24 18:02), Maxim Uvarov wrote:<br>
&gt;<br>
&gt;<br>
&gt;<br>
&gt;<br>
</div>&gt; =A0 =A0 =A0 =A0 2013/5/24 Andrew Morton &lt;<a href=3D"mailto:ak=
pm@linux-foundation.org">akpm@linux-foundation.org</a> &lt;mailto:<a href=
=3D"mailto:akpm@linux-foundation.org">akpm@linux-foundation.org</a>&gt; &lt=
;mailto:<a href=3D"mailto:akpm@linux-foundation.">akpm@linux-foundation.</a=
>__org &lt;mailto:<a href=3D"mailto:akpm@linux-foundation.org">akpm@linux-f=
oundation.org</a>&gt;&gt;&gt;<br>

<div class=3D"im">&gt;<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 On Thu, 23 May 2013 14:25:48 +0900 HATAYAMA Da=
isuke &lt;<a href=3D"mailto:d.hatayama@jp.fujitsu.com">d.hatayama@jp.fujits=
u.com</a> &lt;mailto:<a href=3D"mailto:d.hatayama@jp.fujitsu.com">d.hatayam=
a@jp.fujitsu.com</a>&gt; &lt;mailto:<a href=3D"mailto:d.hatayama@jp.fujitsu=
.">d.hatayama@jp.fujitsu.</a>__com &lt;mailto:<a href=3D"mailto:d.hatayama@=
jp.fujitsu.com">d.hatayama@jp.fujitsu.com</a>&gt;&gt;&gt; wrote:<br>

&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; This patch introduces mmap_vmcore().<b=
r>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; Don&#39;t permit writable nor executab=
le mapping even with mprotect()<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; because this mmap() is aimed at readin=
g crash dump memory.<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; Non-writable mapping is also requireme=
nt of remap_pfn_range() when<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; mapping linear pages on non-consecutiv=
e physical pages; see<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; is_cow_mapping().<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; Set VM_MIXEDMAP flag to remap memory b=
y remap_pfn_range and by<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; remap_vmalloc_range_pertial at the sam=
e time for a single<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; vma. do_munmap() can correctly clean p=
artially remapped vma with two<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; functions in abnormal case. See zap_pt=
e_range(), vm_normal_page() and<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; their comments for details.<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; On x86-32 PAE kernels, mmap() supports=
 at most 16TB memory only. This<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; limitation comes from the fact that th=
e third argument of<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0&gt; remap_pfn_range(), pfn, is of 32-bit l=
ength on x86-32: unsigned long.<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 More reviewing and testing, please.<br>
&gt;<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 Do you have git pull for both kernel and userland chan=
ges? I would like to do some more testing on my machines.<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 Maxim.<br>
&gt;<br>
&gt;<br>
&gt; =A0 =A0 Thanks! That&#39;s very helpful.<br>
&gt;<br>
&gt; =A0 =A0 --<br>
&gt; =A0 =A0 Thanks.<br>
&gt; =A0 =A0 HATAYAMA, Daisuke<br>
&gt;<br>
&gt; Any update for this? Where can I checkout all sources?<br>
<br>
</div>This series is now in Andrew Morton&#39;s -mm tree.<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br></font></span></blockquo=
te><div>Ok, and what about makedumpfile changes? Is it possible to fetch th=
em from somewhere?<br></div><div>=A0</div><blockquote class=3D"gmail_quote"=
 style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<span class=3D"HOEnZb"><font color=3D"#888888">
--<br>
Thanks.<br>
Zhang Yanfei<br>
</font></span></blockquote></div><br><br clear=3D"all"><br>-- <br>Best rega=
rds,<br>Maxim Uvarov
</div></div>

--001a11c2fbd0208b6404ddecfb4e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
