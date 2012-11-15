Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 9C71D6B0074
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 17:13:00 -0500 (EST)
Date: Thu, 15 Nov 2012 14:12:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 50181] New: Memory usage doubles after more then 20 hours
 of uptime.
Message-Id: <20121115141258.8e5cc669.akpm@linux-foundation.org>
In-Reply-To: <1352988349.6409.4.camel@c2d-desktop.mypicture.info>
References: <bug-50181-27@https.bugzilla.kernel.org/>
	<20121113140352.4d2db9e8.akpm@linux-foundation.org>
	<1352988349.6409.4.camel@c2d-desktop.mypicture.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Milos Jakovljevic <sukijaki@gmail.com>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Dave Hansen <dave@linux.vnet.ibm.com>

On Thu, 15 Nov 2012 15:05:49 +0100
Milos Jakovljevic <sukijaki@gmail.com> wrote:

> Here is the requested content:
> 
> free -m: http://pastebin.com/vb878a9Y
> cat /proc/meminfo : http://pastebin.com/zUDFcYEW
> cat /proc/slabinfo : http://pastebin.com/kswsJ7Hk
> cat /proc/vmstat : http://pastebin.com/wUebJqJe
> 
> dmesg -c : http://pastebin.com/f7cTu8Wv
> 
> echo m > /proc/sysrq-trigger && dmesg : http://pastebin.com/p68DcHUy
> 
> And here are also files with that content:
> http://ubuntuone.com/5GUVahBTiZRP0QjQdP3gkQ
> 

You've lost 2-3GB of ZONE_NORMAL and I see no sign there to indicate
where it went.

/proc/slabinfo indicates that it isn't a slab leak, and kmemleak won't
tell us about alloc_pages() leaks.  I'm stumped.  Dave, any progress at
your end?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
