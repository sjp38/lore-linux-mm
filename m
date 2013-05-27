Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 81F266B00EB
	for <linux-mm@kvack.org>; Sun, 26 May 2013 21:49:47 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 982823EE0BC
	for <linux-mm@kvack.org>; Mon, 27 May 2013 10:49:45 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8807845DE55
	for <linux-mm@kvack.org>; Mon, 27 May 2013 10:49:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F85445DE4F
	for <linux-mm@kvack.org>; Mon, 27 May 2013 10:49:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C3C3E08005
	for <linux-mm@kvack.org>; Mon, 27 May 2013 10:49:45 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EF0DBE08001
	for <linux-mm@kvack.org>; Mon, 27 May 2013 10:49:44 +0900 (JST)
Message-ID: <51A2BBA7.50607@jp.fujitsu.com>
Date: Mon, 27 May 2013 10:49:27 +0900
From: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 9/9] vmcore: support mmap() on /proc/vmcore
References: <20130523052421.13864.83978.stgit@localhost6.localdomain6> <20130523052547.13864.83306.stgit@localhost6.localdomain6> <20130523152445.17549682ae45b5aab3f3cde0@linux-foundation.org> <CAJGZr0LwivLTH+E7WAR1B9_6B4e=jv04KgCUL_PdVpi9JjDpBw@mail.gmail.com>
In-Reply-To: <CAJGZr0LwivLTH+E7WAR1B9_6B4e=jv04KgCUL_PdVpi9JjDpBw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxim Uvarov <muvarov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, hughd@google.com, jingbai.ma@hp.com, "kexec@lists.infradead.org" <kexec@lists.infradead.org>, linux-kernel@vger.kernel.org, lisa.mitchell@hp.com, linux-mm@kvack.org, Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>, "Eric W. Biederman" <ebiederm@xmission.com>, kosaki.motohiro@jp.fujitsu.com, zhangyanfei@cn.fujitsu.com, walken@google.com, Cliff Wickman <cpw@sgi.com>, Vivek Goyal <vgoyal@redhat.com>

(2013/05/24 18:02), Maxim Uvarov wrote:
>
>
>
> 2013/5/24 Andrew Morton <akpm@linux-foundation.org <mailto:akpm@linux-foundation.org>>
>
>     On Thu, 23 May 2013 14:25:48 +0900 HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com <mailto:d.hatayama@jp.fujitsu.com>> wrote:
>
>      > This patch introduces mmap_vmcore().
>      >
>      > Don't permit writable nor executable mapping even with mprotect()
>      > because this mmap() is aimed at reading crash dump memory.
>      > Non-writable mapping is also requirement of remap_pfn_range() when
>      > mapping linear pages on non-consecutive physical pages; see
>      > is_cow_mapping().
>      >
>      > Set VM_MIXEDMAP flag to remap memory by remap_pfn_range and by
>      > remap_vmalloc_range_pertial at the same time for a single
>      > vma. do_munmap() can correctly clean partially remapped vma with two
>      > functions in abnormal case. See zap_pte_range(), vm_normal_page() and
>      > their comments for details.
>      >
>      > On x86-32 PAE kernels, mmap() supports at most 16TB memory only. This
>      > limitation comes from the fact that the third argument of
>      > remap_pfn_range(), pfn, is of 32-bit length on x86-32: unsigned long.
>
>     More reviewing and testing, please.
>
>
> Do you have git pull for both kernel and userland changes? I would like to do some more testing on my machines.
>
> Maxim.

Thanks! That's very helpful.

-- 
Thanks.
HATAYAMA, Daisuke

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
