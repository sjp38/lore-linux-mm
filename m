Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5B39B6B0071
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 03:57:13 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0D8vApl020464
	for <linux-mm@kvack.org> (envelope-from d.hatayama@jp.fujitsu.com);
	Wed, 13 Jan 2010 17:57:11 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 81DE545DE50
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 17:57:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5074C45DE4E
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 17:57:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2EBE1E38008
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 17:57:10 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D688DE38005
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 17:57:09 +0900 (JST)
Date: Wed, 13 Jan 2010 17:57:22 +0900 (JST)
Message-Id: <20100113.175722.193708555.d.hatayama@jp.fujitsu.com>
Subject: Re: [RESEND][mmotm][PATCH v2, 0/5] elf coredump: Add extended
 numbering support
From: Daisuke HATAYAMA <d.hatayama@jp.fujitsu.com>
In-Reply-To: <20100111192418.5cd8a554.akpm@linux-foundation.org>
References: <20100107162928.1d6eba76.akpm@linux-foundation.org>
	<20100112.121232.189721840.d.hatayama@jp.fujitsu.com>
	<20100111192418.5cd8a554.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhiramat@redhat.com, xiyou.wangcong@gmail.com, andi@firstfloor.org, jdike@addtoit.com, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND][mmotm][PATCH v2, 0/5] elf coredump: Add extended numbering support
Date: Mon, 11 Jan 2010 19:24:18 -0800

> On Tue, 12 Jan 2010 12:12:32 +0900 (JST) Daisuke HATAYAMA <d.hatayama@jp.fujitsu.com> wrote:
> 
>> From: Andrew Morton <akpm@linux-foundation.org>
>> Subject: Re: [RESEND][mmotm][PATCH v2, 0/5] elf coredump: Add extended numbering support
>> Date: Thu, 7 Jan 2010 16:29:28 -0800
>> 
>> > On Mon, 04 Jan 2010 10:06:07 +0900 (JST)
>> > Daisuke HATAYAMA <d.hatayama@jp.fujitsu.com> wrote:
>> > 
>> > > The current ELF dumper can produce broken corefiles if program headers
>> > > exceed 65535. In particular, the program in 64-bit environment often
>> > > demands more than 65535 mmaps. If you google max_map_count, then you
>> > > can find many users facing this problem.
>> > > 
>> > > Solaris has already dealt with this issue, and other OSes have also
>> > > adopted the same method as in Solaris. Currently, Sun's document and
>> > > AMD 64 ABI include the description for the extension, where they call
>> > > the extension Extended Numbering. See Reference for further information.
>> > > 
>> > > I believe that linux kernel should adopt the same way as they did, so
>> > > I've written this patch.
>> > > 
>> > > I am also preparing for patches of GDB and binutils.
>> > 
>> > That's a beautifully presented patchset.  Thanks for doing all that
>> > work - it helps.
>> > 
>> > UML maintenance appears to have ceased in recent times, so if we wish
>> > to have these changes runtime tested (we should) then I think it would
>> > be best if you could find someone to do that please.
>> > 
>> > And no akpm code-review would be complete without: dump_seek() is
>> > waaaay to large to be inlined.  Is there some common .c file to where
>> > we could move it?
>> > 
>> 
>> * Patch Test for UML-i386
>> 
>> I tested on UML-i386 for the stable release of that time, precisely
>> 2.6.32, since even building process for UML-i386 failed for mainline
>> and mmotm trees, as you've expected.
>> 
>> I don't know internal UML implementation at all, so I need to find
>> someone if runtime test for mmotm tree is absolutely necessary.
> 
> OK, thanks.
> 

I'd like to correct the above.

UML-i386 can successfully be built and run by using default config
file for v2.6.32.11, v2.6.33-rc3 and current git mmotm tree,
respectively.

I have yet to do build test by allmodconfig.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
