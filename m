Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 9CF946B0034
	for <linux-mm@kvack.org>; Thu, 30 May 2013 05:14:08 -0400 (EDT)
Received: by mail-ob0-f171.google.com with SMTP id dn14so6176obc.16
        for <linux-mm@kvack.org>; Thu, 30 May 2013 02:14:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <51A2BBA7.50607@jp.fujitsu.com>
References: <20130523052421.13864.83978.stgit@localhost6.localdomain6>
	<20130523052547.13864.83306.stgit@localhost6.localdomain6>
	<20130523152445.17549682ae45b5aab3f3cde0@linux-foundation.org>
	<CAJGZr0LwivLTH+E7WAR1B9_6B4e=jv04KgCUL_PdVpi9JjDpBw@mail.gmail.com>
	<51A2BBA7.50607@jp.fujitsu.com>
Date: Thu, 30 May 2013 13:14:07 +0400
Message-ID: <CAJGZr0LmsFXEgb3UXVb+rqo1aq5KJyNxyNAD+DG+3KnJm_ZncQ@mail.gmail.com>
Subject: Re: [PATCH v8 9/9] vmcore: support mmap() on /proc/vmcore
From: Maxim Uvarov <muvarov@gmail.com>
Content-Type: multipart/alternative; boundary=001a11c238a8a96d1204ddebebd7
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, hughd@google.com, jingbai.ma@hp.com, "kexec@lists.infradead.org" <kexec@lists.infradead.org>, linux-kernel@vger.kernel.org, lisa.mitchell@hp.com, linux-mm@kvack.org, Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>, "Eric W. Biederman" <ebiederm@xmission.com>, kosaki.motohiro@jp.fujitsu.com, zhangyanfei@cn.fujitsu.com, walken@google.com, Cliff Wickman <cpw@sgi.com>, Vivek Goyal <vgoyal@redhat.com>

--001a11c238a8a96d1204ddebebd7
Content-Type: text/plain; charset=ISO-8859-1

2013/5/27 HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>

> (2013/05/24 18:02), Maxim Uvarov wrote:
>
>>
>>
>>
>> 2013/5/24 Andrew Morton <akpm@linux-foundation.org <mailto:
>> akpm@linux-foundation.**org <akpm@linux-foundation.org>>>
>>
>>
>>     On Thu, 23 May 2013 14:25:48 +0900 HATAYAMA Daisuke <
>> d.hatayama@jp.fujitsu.com <mailto:d.hatayama@jp.fujitsu.**com<d.hatayama@jp.fujitsu.com>>>
>> wrote:
>>
>>      > This patch introduces mmap_vmcore().
>>      >
>>      > Don't permit writable nor executable mapping even with mprotect()
>>      > because this mmap() is aimed at reading crash dump memory.
>>      > Non-writable mapping is also requirement of remap_pfn_range() when
>>      > mapping linear pages on non-consecutive physical pages; see
>>      > is_cow_mapping().
>>      >
>>      > Set VM_MIXEDMAP flag to remap memory by remap_pfn_range and by
>>      > remap_vmalloc_range_pertial at the same time for a single
>>      > vma. do_munmap() can correctly clean partially remapped vma with
>> two
>>      > functions in abnormal case. See zap_pte_range(), vm_normal_page()
>> and
>>      > their comments for details.
>>      >
>>      > On x86-32 PAE kernels, mmap() supports at most 16TB memory only.
>> This
>>      > limitation comes from the fact that the third argument of
>>      > remap_pfn_range(), pfn, is of 32-bit length on x86-32: unsigned
>> long.
>>
>>     More reviewing and testing, please.
>>
>>
>> Do you have git pull for both kernel and userland changes? I would like
>> to do some more testing on my machines.
>>
>> Maxim.
>>
>
> Thanks! That's very helpful.
>
> --
> Thanks.
> HATAYAMA, Daisuke
>
> Any update for this? Where can I checkout all sources?

-- 
Best regards,
Maxim Uvarov

--001a11c238a8a96d1204ddebebd7
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><br><div class=3D"gmail=
_quote">2013/5/27 HATAYAMA Daisuke <span dir=3D"ltr">&lt;<a href=3D"mailto:=
d.hatayama@jp.fujitsu.com" target=3D"_blank">d.hatayama@jp.fujitsu.com</a>&=
gt;</span><br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">(2013/05/24 18:02), Maxim Uvarov wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
<br>
<br>
<br>
2013/5/24 Andrew Morton &lt;<a href=3D"mailto:akpm@linux-foundation.org" ta=
rget=3D"_blank">akpm@linux-foundation.org</a> &lt;mailto:<a href=3D"mailto:=
akpm@linux-foundation.org" target=3D"_blank">akpm@linux-foundation.<u></u>o=
rg</a>&gt;&gt;<div class=3D"im">
<br>
<br>
=A0 =A0 On Thu, 23 May 2013 14:25:48 +0900 HATAYAMA Daisuke &lt;<a href=3D"=
mailto:d.hatayama@jp.fujitsu.com" target=3D"_blank">d.hatayama@jp.fujitsu.c=
om</a> &lt;mailto:<a href=3D"mailto:d.hatayama@jp.fujitsu.com" target=3D"_b=
lank">d.hatayama@jp.fujitsu.<u></u>com</a>&gt;&gt; wrote:<br>

<br>
=A0 =A0 =A0&gt; This patch introduces mmap_vmcore().<br>
=A0 =A0 =A0&gt;<br>
=A0 =A0 =A0&gt; Don&#39;t permit writable nor executable mapping even with =
mprotect()<br>
=A0 =A0 =A0&gt; because this mmap() is aimed at reading crash dump memory.<=
br>
=A0 =A0 =A0&gt; Non-writable mapping is also requirement of remap_pfn_range=
() when<br>
=A0 =A0 =A0&gt; mapping linear pages on non-consecutive physical pages; see=
<br>
=A0 =A0 =A0&gt; is_cow_mapping().<br>
=A0 =A0 =A0&gt;<br>
=A0 =A0 =A0&gt; Set VM_MIXEDMAP flag to remap memory by remap_pfn_range and=
 by<br>
=A0 =A0 =A0&gt; remap_vmalloc_range_pertial at the same time for a single<b=
r>
=A0 =A0 =A0&gt; vma. do_munmap() can correctly clean partially remapped vma=
 with two<br>
=A0 =A0 =A0&gt; functions in abnormal case. See zap_pte_range(), vm_normal_=
page() and<br>
=A0 =A0 =A0&gt; their comments for details.<br>
=A0 =A0 =A0&gt;<br>
=A0 =A0 =A0&gt; On x86-32 PAE kernels, mmap() supports at most 16TB memory =
only. This<br>
=A0 =A0 =A0&gt; limitation comes from the fact that the third argument of<b=
r>
=A0 =A0 =A0&gt; remap_pfn_range(), pfn, is of 32-bit length on x86-32: unsi=
gned long.<br>
<br>
=A0 =A0 More reviewing and testing, please.<br>
<br>
<br>
Do you have git pull for both kernel and userland changes? I would like to =
do some more testing on my machines.<br>
<br>
Maxim.<br>
</div></blockquote>
<br>
Thanks! That&#39;s very helpful.<span class=3D"HOEnZb"><font color=3D"#8888=
88"><br>
<br>
-- <br>
Thanks.<br>
HATAYAMA, Daisuke<br>
<br>
</font></span></blockquote></div>Any update for this? Where can I checkout =
all sources? <br></div><div class=3D"gmail_extra"><br>-- <br>Best regards,<=
br>Maxim Uvarov
</div></div>

--001a11c238a8a96d1204ddebebd7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
