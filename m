Message-ID: <40517E47.3010909@cyberone.com.au>
Date: Fri, 12 Mar 2004 20:09:27 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] 2.6.4-rc2-mm1: vm-split-active-lists
References: <404FACF4.3030601@cyberone.com.au> <200403111825.22674@WOLK>
In-Reply-To: <200403111825.22674@WOLK>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marc-Christian Petersen <m.c.p@wolk-project.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mike Fedyk <mfedyk@matchmail.com>, plate@gmx.tm
List-ID: <linux-mm.kvack.org>


Marc-Christian Petersen wrote:

>On Thursday 11 March 2004 01:04, Nick Piggin wrote:
>
>Hi Nick,
>
>
>>Here is my updated patches rolled into one.
>>
>
>hmm, using this in 2.6.4-rc2-mm1 my machine starts to swap very very soon. 
>Machine has squid, bind, apache running, X 4.3.0, Windowmaker, so nothing 
>special.
>
>Swap grows very easily starting to untar'gunzip a kernel tree. About + 
>150-200MB goes to swap. Everything is very smooth though, but I just wondered 
>because w/o your patches swap isn't used at all, even after some days of 
>uptime.
>
>

Hmm... I guess it is still smooth because it is swapping out only
inactive pages. If the standard VM isn't being pushed very hard it
doesn't scan mapped pages at all which is why it isn't swapping.

I have a preference for allowing it to scan some mapped pages though.
I'm not sure if there is any attempt at a drop behind logic. That
might help. Add new unmapped pagecache pages to the inactive list or
something might help... hmm, actually that's what it does now by the
looks.

I guess you don't have a problem though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
