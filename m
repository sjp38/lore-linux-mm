Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id F064B6B00CE
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 17:11:26 -0400 (EDT)
Message-ID: <506DFB79.1040307@googlemail.com>
Date: Thu, 04 Oct 2012 23:11:21 +0200
From: =?ISO-8859-1?Q?Holger_Hoffst=E4tte?=
 <holger.hoffstaette@googlemail.com>
MIME-Version: 1.0
Subject: Re: Repeatable ext4 oops with 3.6.0 (regression)
References: <pan.2012.10.02.11.19.55.793436@googlemail.com> <20121002133642.GD22777@quack.suse.cz> <pan.2012.10.02.14.31.57.530230@googlemail.com> <20121004130119.GH4641@quack.suse.cz> <506DABDD.7090105@googlemail.com> <20121004173425.GA15405@thunk.org>
In-Reply-To: <20121004173425.GA15405@thunk.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org, linux-mm@kvack.org

(dear -mm: please see
http://thread.gmane.org/gmane.comp.file-systems.ext4/34665 for the
origins of this oops)

On 10/04/12 19:34, Theodore Ts'o wrote:
> On Thu, Oct 04, 2012 at 05:31:41PM +0200, Holger Hoffstatte wrote:
> 
>> So armed with multiple running shells I finally managed to save the dmesg
>> to NFS. It doesn't get any more complete than this and again shows the
>> ext4 stacktrace from before. So maybe it really is generic kmem corruption
>> and ext4 looking at symlinks/inodes is just the victim.
> 
> That certainly seems to be the case.  As near as I can tell from the

Good to know. Unfortunately I'm still at a loss why apparently only
gthumb can trigger this; I had not noticed any other problems with 3.6.0
before that (ran it for half a day, desktop use).

> So it's very likely that the crash in __kmalloc() is probably caused
> by the internal slab/slub data structures getting scrambled.

For giggles I rebuilt with SLAB instead of SLUB, but no luck; same
segfault and delayed oopsie. I also collected an strace, but I cannot
really see anything out of the ordinary - it starts, loads things,
traverses directories and then segfaults.

I've put the earlier full dmesg and the strace into
http://hoho.dyndns.org/~holger/ext4-oops-3.6.0/ - maybe it helps someone
else.

Any suggestions for memory debugging? I saw several options in the
kernel config (under "Kernel Hacking") but was not sure what to enable.

Holger

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
