Date: Tue, 22 May 2007 11:34:04 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [Patch] memory unplug v3 [0/4]
In-Reply-To: <20070522155824.563f5873.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0705221133070.29456@schroedinger.engr.sgi.com>
References: <20070522155824.563f5873.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux-MM <linux-mm@kvack.org>, mel@csn.ul.ie, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, 22 May 2007, KAMEZAWA Hiroyuki wrote:

>  - user kernelcore=XXX boot option to create ZONE_MOVABLE.
>    Memory unplug itself can work without ZONE_MOVABLE but it will be
>    better to use kernelcore= if your section size is big.

Hmmm.... Sure wish the ZONE_MOVABLE would go away. Isnt there some way to 
have a dynamic boundary within ZONE_NORMAL?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
