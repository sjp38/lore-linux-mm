Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 3A2D76B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 22:53:49 -0400 (EDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <20130515090507.28109.28956.stgit@localhost6.localdomain6>
	<51957469.2000008@zytor.com>
Date: Thu, 16 May 2013 19:53:31 -0700
In-Reply-To: <51957469.2000008@zytor.com> (H. Peter Anvin's message of "Thu,
	16 May 2013 17:06:01 -0700")
Message-ID: <87y5bee2qc.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH v6 0/8] kdump, vmcore: support mmap() on /proc/vmcore
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, vgoyal@redhat.com, akpm@linux-foundation.org, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

"H. Peter Anvin" <hpa@zytor.com> writes:

> On 05/15/2013 02:05 AM, HATAYAMA Daisuke wrote:
>> Currently, read to /proc/vmcore is done by read_oldmem() that uses
>> ioremap/iounmap per a single page. For example, if memory is 1GB,
>> ioremap/iounmap is called (1GB / 4KB)-times, that is, 262144
>> times. This causes big performance degradation.
>
> read_oldmem() is fundamentally broken and unsafe.  It needs to be
> unified with the plain /dev/mem code and any missing functionality fixed
> instead of "let's just do a whole new driver".

That is completely and totally orthogonal to this change.

read_oldmem may have problems but in practice on a large systems those
problems are totally dwarfed by real life performance issues that come
from playing too much with the page tables.

I really don't find bringing up whatever foundational issues you have
with read_oldmem() appropriate or relevant here.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
