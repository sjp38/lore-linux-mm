Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <akpm@digeo.com>) (for <linux-kernel@vger.kernel.org>)
	(for <linux-mm@kvack.org>) By tone With Smtp ;
	Sun, 15 Jun 2003 20:15:10 +1000
From: Neil Brown <neilb@cse.unsw.edu.au>
Date: Sun, 15 Jun 2003 20:19:27 +1000
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16108.18479.941335.176904@gargle.gargle.HOWL>
Subject: Re: 2.5.71-mm1
In-Reply-To: message from Andrew Morton on Sunday June 15
References: <20030615015024.6d868168.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sunday June 15, akpm@digeo.com wrote:
> 
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.71/2.5.71-mm1/
> 
> 
> Mainly a resync.
> 
> . Manfred sent me a revised unmap-page-debugging patch which promptly
>   broke.  All slab changes have been dropped out so he can have a clear run
>   at that.
> 
> . New toy.  Called, for the lack of a better name, "sleepometer":
> 

New toy seems to be lacking mainspring...

In particular,  sleepo.h cannot be found :-(

NeilBrown
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
