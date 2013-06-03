Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id D3B366B003D
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 05:04:17 -0400 (EDT)
Date: Mon, 3 Jun 2013 17:43:51 +0900
From: Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>
Subject: Re: [PATCH v8 9/9] vmcore: support mmap() on /proc/vmcore
Message-Id: <20130603174351.d04b2ac71d1bab0df242e0ba@mxc.nes.nec.co.jp>
In-Reply-To: <CAJGZr0Ld6Q4a4f-VObAbvqCp=+fTFNEc6M-Fdnhh28GTcSm1=w@mail.gmail.com>
References: <20130523052421.13864.83978.stgit@localhost6.localdomain6>
	<20130523052547.13864.83306.stgit@localhost6.localdomain6>
	<20130523152445.17549682ae45b5aab3f3cde0@linux-foundation.org>
	<CAJGZr0LwivLTH+E7WAR1B9_6B4e=jv04KgCUL_PdVpi9JjDpBw@mail.gmail.com>
	<51A2BBA7.50607@jp.fujitsu.com>
	<CAJGZr0LmsFXEgb3UXVb+rqo1aq5KJyNxyNAD+DG+3KnJm_ZncQ@mail.gmail.com>
	<51A71B49.3070003@cn.fujitsu.com>
	<CAJGZr0Ld6Q4a4f-VObAbvqCp=+fTFNEc6M-Fdnhh28GTcSm1=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: muvarov@gmail.com
Cc: zhangyanfei@cn.fujitsu.com, d.hatayama@jp.fujitsu.com, akpm@linux-foundation.org, riel@redhat.com, hughd@google.com, jingbai.ma@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, lisa.mitchell@hp.com, linux-mm@kvack.org, ebiederm@xmission.com, kosaki.motohiro@jp.fujitsu.com, walken@google.com, cpw@sgi.com, vgoyal@redhat.com

Hello Maxim,

On Thu, 30 May 2013 14:30:01 +0400
Maxim Uvarov <muvarov@gmail.com> wrote:

> 2013/5/30 Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> 
> > On 05/30/2013 05:14 PM, Maxim Uvarov wrote:
> > >
> > >
> > >
> > > 2013/5/27 HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com <mailto:
> > d.hatayama@jp.fujitsu.com>>
> > >
> > >     (2013/05/24 18:02), Maxim Uvarov wrote:
> > >
> > >
> > >
> > >
> > >         2013/5/24 Andrew Morton <akpm@linux-foundation.org <mailto:
> > akpm@linux-foundation.org> <mailto:akpm@linux-foundation.__org <mailto:
> > akpm@linux-foundation.org>>>
> > >
> > >
> > >             On Thu, 23 May 2013 14:25:48 +0900 HATAYAMA Daisuke <
> > d.hatayama@jp.fujitsu.com <mailto:d.hatayama@jp.fujitsu.com> <mailto:
> > d.hatayama@jp.fujitsu.__com <mailto:d.hatayama@jp.fujitsu.com>>> wrote:
> > >
> > >              > This patch introduces mmap_vmcore().
> > >              >
> > >              > Don't permit writable nor executable mapping even with
> > mprotect()
> > >              > because this mmap() is aimed at reading crash dump memory.
> > >              > Non-writable mapping is also requirement of
> > remap_pfn_range() when
> > >              > mapping linear pages on non-consecutive physical pages;
> > see
> > >              > is_cow_mapping().
> > >              >
> > >              > Set VM_MIXEDMAP flag to remap memory by remap_pfn_range
> > and by
> > >              > remap_vmalloc_range_pertial at the same time for a single
> > >              > vma. do_munmap() can correctly clean partially remapped
> > vma with two
> > >              > functions in abnormal case. See zap_pte_range(),
> > vm_normal_page() and
> > >              > their comments for details.
> > >              >
> > >              > On x86-32 PAE kernels, mmap() supports at most 16TB
> > memory only. This
> > >              > limitation comes from the fact that the third argument of
> > >              > remap_pfn_range(), pfn, is of 32-bit length on x86-32:
> > unsigned long.
> > >
> > >             More reviewing and testing, please.
> > >
> > >
> > >         Do you have git pull for both kernel and userland changes? I
> > would like to do some more testing on my machines.
> > >
> > >         Maxim.
> > >
> > >
> > >     Thanks! That's very helpful.
> > >
> > >     --
> > >     Thanks.
> > >     HATAYAMA, Daisuke
> > >
> > > Any update for this? Where can I checkout all sources?
> >
> > This series is now in Andrew Morton's -mm tree.
> >
> > Ok, and what about makedumpfile changes? Is it possible to fetch them from
> somewhere?

You can fetch them from here, "mmap" branch is the change:

  git://git.code.sf.net/p/makedumpfile/code

And they will be merged into v1.5.4.


Thanks
Atsushi Kumagai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
