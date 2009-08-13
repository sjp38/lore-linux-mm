Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E724F6B0055
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 12:13:22 -0400 (EDT)
Received: by pzk28 with SMTP id 28so646820pzk.11
        for <linux-mm@kvack.org>; Thu, 13 Aug 2009 09:13:25 -0700 (PDT)
Message-ID: <4A843B96.3010200@vflare.org>
Date: Thu, 13 Aug 2009 21:43:10 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
 slot is freed)
References: <200908122007.43522.ngupta@vflare.org> <Pine.LNX.4.64.0908122312380.25501@sister.anvils> <20090813151312.GA13559@linux.intel.com>
In-Reply-To: <20090813151312.GA13559@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 08/13/2009 08:43 PM, Matthew Wilcox wrote:

>
> I am planning a complete overhaul of the discard work.  Users can send
> down discard requests as frequently as they like.  The block layer will
> cache them, and invalidate them if writes come through.  Periodically,
> the block layer will send down a TRIM or an UNMAP (depending on the
> underlying device) and get rid of the blocks that have remained unwanted
> in the interim.
>

This batching of discard requests is still sub-optimal for compcache. 
The optimal solution in this case is to get callback *as soon as* a swap 
slot becomes free and this is what this patch does.

I see that it will be difficult to accept this patch since compcache 
seems to be the only user for now. However, this little addition makes a 
*big* difference for the project. Currently, much of memory is wasted to 
store all the stale data.

I will be posting compcache patches for review in next merge window. So, 
maybe this patch can be included now as the first step? The revised 
patch is ready which addresses issues raised during the first review -- 
will post it soon.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
