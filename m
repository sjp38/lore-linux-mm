Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7073A6B003D
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 19:30:19 -0500 (EST)
Date: Thu, 7 Jan 2010 16:29:28 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND][mmotm][PATCH v2, 0/5] elf coredump: Add extended
 numbering support
Message-Id: <20100107162928.1d6eba76.akpm@linux-foundation.org>
In-Reply-To: <20100104.100607.189714443.d.hatayama@jp.fujitsu.com>
References: <20100104.100607.189714443.d.hatayama@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke HATAYAMA <d.hatayama@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhiramat@redhat.com, xiyou.wangcong@gmail.com, andi@firstfloor.org, jdike@addtoit.com, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

On Mon, 04 Jan 2010 10:06:07 +0900 (JST)
Daisuke HATAYAMA <d.hatayama@jp.fujitsu.com> wrote:

> The current ELF dumper can produce broken corefiles if program headers
> exceed 65535. In particular, the program in 64-bit environment often
> demands more than 65535 mmaps. If you google max_map_count, then you
> can find many users facing this problem.
> 
> Solaris has already dealt with this issue, and other OSes have also
> adopted the same method as in Solaris. Currently, Sun's document and
> AMD 64 ABI include the description for the extension, where they call
> the extension Extended Numbering. See Reference for further information.
> 
> I believe that linux kernel should adopt the same way as they did, so
> I've written this patch.
> 
> I am also preparing for patches of GDB and binutils.

That's a beautifully presented patchset.  Thanks for doing all that
work - it helps.

UML maintenance appears to have ceased in recent times, so if we wish
to have these changes runtime tested (we should) then I think it would
be best if you could find someone to do that please.

And no akpm code-review would be complete without: dump_seek() is
waaaay to large to be inlined.  Is there some common .c file to where
we could move it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
