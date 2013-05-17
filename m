Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 93C406B0032
	for <linux-mm@kvack.org>; Fri, 17 May 2013 00:29:17 -0400 (EDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <20130515090507.28109.28956.stgit@localhost6.localdomain6>
	<51957469.2000008@zytor.com> <87y5bee2qc.fsf@xmission.com>
	<5195A223.2070204@zytor.com>
Date: Thu, 16 May 2013 21:29:03 -0700
In-Reply-To: <5195A223.2070204@zytor.com> (H. Peter Anvin's message of "Thu,
	16 May 2013 20:21:07 -0700")
Message-ID: <87vc6icjqo.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH v6 0/8] kdump, vmcore: support mmap() on /proc/vmcore
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, vgoyal@redhat.com, akpm@linux-foundation.org, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

"H. Peter Anvin" <hpa@zytor.com> writes:

> On 05/16/2013 07:53 PM, Eric W. Biederman wrote:
>> 
>> That is completely and totally orthogonal to this change.
>> 
>> read_oldmem may have problems but in practice on a large systems those
>> problems are totally dwarfed by real life performance issues that come
>> from playing too much with the page tables.
>> 
>> I really don't find bringing up whatever foundational issues you have
>> with read_oldmem() appropriate or relevant here.
>> 
>
> Well, it is in the sense that we have two pieces of code doing the same
> thing, each with different bugs.

Not a the tiniest little bit.

All this patchset is about is which page table kernel vs user we map the
physical addresses in.

As such this patchset should neither increase nor decrease the number of
bugs, or cause any other hilarity.

Whatever theoretical issues you have with /dev/oldmem and /proc/vmcore
can and should be talked about and addressed independently of these
changes.  HATMAYA Daisuke already has enough to handle coming up with a
clean set of patches that add mmap support.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
