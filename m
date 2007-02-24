Date: Fri, 23 Feb 2007 21:47:36 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: SLUB: The unqueued Slab allocator
In-Reply-To: <20070224142835.4c7a3207.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0702232145340.1872@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702212250271.30485@schroedinger.engr.sgi.com>
 <p73hctecc3l.fsf@bingen.suse.de> <Pine.LNX.4.64.0702221040140.2011@schroedinger.engr.sgi.com>
 <20070224142835.4c7a3207.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: andi@firstfloor.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 24 Feb 2007, KAMEZAWA Hiroyuki wrote:

> >From a viewpoint of a crash dump user, this merging will make crash dump
> investigation very very very difficult.

The general caches already merge lots of users depending on their sizes. 
So we already have the situation and we have tools to deal with it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
