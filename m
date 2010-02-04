Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9A13B6B0047
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 22:19:00 -0500 (EST)
Date: Thu, 4 Feb 2010 11:18:54 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [stable] [PATCH] devmem: check vmalloc address on kmem
	read/write
Message-ID: <20100204031854.GA14324@localhost>
References: <20100122045914.993668874@intel.com> <20100203234724.GA23902@kroah.com> <20100204024202.GD6343@localhost> <20100204115801.cac7c342.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100204115801.cac7c342.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@suse.de>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "stable@kernel.org" <stable@kernel.org>, "juha_motorsportcom@luukku.com" <juha_motorsportcom@luukku.com>
List-ID: <linux-mm.kvack.org>

On Thu, Feb 04, 2010 at 10:58:01AM +0800, KAMEZAWA Hiroyuki wrote:
> On Thu, 4 Feb 2010 10:42:02 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > commit 325fda71d0badc1073dc59f12a948f24ff05796a upstream.
> > 
> > Otherwise vmalloc_to_page() will BUG().
> > 
> > This also makes the kmem read/write implementation aligned with mem(4):
> > "References to nonexistent locations cause errors to be returned." Here
> > we return -ENXIO (inspired by Hugh) if no bytes have been transfered
> > to/from user space, otherwise return partial read/write results.
> > 
> 
> Wu-san, I have additonal fix to this patch. Now, *ppos update is unstable..
> Could you make merged one ?
> Maybe this one makes the all behavior clearer.
> 
> ==
> This is a more fix for devmem-check-vmalloc-address-on-kmem-read-write.patch
> Now, the condition for updating *ppos is not good. (it's updated even if EFAULT
> occurs..). This fixes that.
> 
> 
> Reported-by: "Juha Leppanen" <juha_motorsportcom@luukku.com>

Sorry, can you elaborate the problem? How it break the application?

It looks that do_generic_file_read() also updates *ppos progressively,
no one complains about that.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
