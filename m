From: Neil Brown <neilb@suse.de>
Date: Tue, 1 May 2007 19:52:11 +1000
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17975.3531.838077.563475@notabene.brown>
Subject: Re: nfsd/md patches Re: 2.6.22 -mm merge plans
In-Reply-To: message from Christoph Hellwig on Tuesday May 1
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	<17974.34116.479061.912980@notabene.brown>
	<20070501090843.GB17949@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday May 1, hch@infradead.org wrote:
> apropos nfsd patches, what's the merge plans for my two export ops
> patch series?

Still sitting in my tree - I've had my mind on other things
(nfs-utils, portmap....) and let them slip - sorry.

I think also there was an unanswered question about the second series
(there first I am completely happy with).

> Date: Fri, 30 Mar 2007 13:34:53 +1000
> 
> My only question involves motivation.
> 
>   You say "less complex", but to me it just looks "different" - though
>   being very familiar with the original, that might be a biased view.
>   Can you say more about how it is less complex?
>   Maybe the extension to generic 64bit support will make that clear...
> 
>   But then generic 64bit support should just be an independent set of
>   helper functions that can be plugged in to the export_operations
>   structure.
> 

It think I programmed myself to use a reply to that to be my wake_up
to forwarded them on, and forgot to register a timeout handler....

NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
