Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 0FDFB6B004D
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:11:49 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so56302eaa.14
        for <linux-mm@kvack.org>; Thu, 15 Nov 2012 15:11:47 -0800 (PST)
Message-ID: <1353021103.6409.31.camel@c2d-desktop.mypicture.info>
Subject: Re: [Bug 50181] New: Memory usage doubles after more then 20 hours
 of uptime.
From: Milos Jakovljevic <sukijaki@gmail.com>
Date: Fri, 16 Nov 2012 00:11:43 +0100
In-Reply-To: <20121115141258.8e5cc669.akpm@linux-foundation.org>
References: <bug-50181-27@https.bugzilla.kernel.org/>
	 <20121113140352.4d2db9e8.akpm@linux-foundation.org>
	 <1352988349.6409.4.camel@c2d-desktop.mypicture.info>
	 <20121115141258.8e5cc669.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Dave Hansen <dave@linux.vnet.ibm.com>

On Thu, 2012-11-15 at 14:12 -0800, Andrew Morton wrote: 
> On Thu, 15 Nov 2012 15:05:49 +0100
> Milos Jakovljevic <sukijaki@gmail.com> wrote:
> 
> > Here is the requested content:
> > 
> > free -m: http://pastebin.com/vb878a9Y
> > cat /proc/meminfo : http://pastebin.com/zUDFcYEW
> > cat /proc/slabinfo : http://pastebin.com/kswsJ7Hk
> > cat /proc/vmstat : http://pastebin.com/wUebJqJe
> > 
> > dmesg -c : http://pastebin.com/f7cTu8Wv
> > 
> > echo m > /proc/sysrq-trigger && dmesg : http://pastebin.com/p68DcHUy
> > 
> > And here are also files with that content:
> > http://ubuntuone.com/5GUVahBTiZRP0QjQdP3gkQ
> > 
> 
> You've lost 2-3GB of ZONE_NORMAL and I see no sign there to indicate
> where it went.
> 
> /proc/slabinfo indicates that it isn't a slab leak, and kmemleak won't
> tell us about alloc_pages() leaks.  I'm stumped.  Dave, any progress at
> your end?
> 
> 
I didn't understood anything you sad, but never mind. 

In -rc2 there was a problem with massive iowait when anything was done
(starting an app, loading a web page, etc ...), and there was a massive
read operation from my /home partition. In -rc3 that stopped, and this
started happening. Maybe it is related somehow?

Or maybe, it is just some problem with nvidia blob and 3.7 kernel
loosing VM_RELEASE  (in a blob's mmap.c it was replaced with
VM_DONTEXPAND | VM_DONTDUMP ).  - or maybe I'm just saying nonsense
here.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
