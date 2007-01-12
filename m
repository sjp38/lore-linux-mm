Message-ID: <45A6D118.5030508@yahoo.com.au>
Date: Fri, 12 Jan 2007 11:06:48 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [REGRESSION] 2.6.19/2.6.20-rc3 buffered write slowdown
References: <20070110223731.GC44411608@melbourne.sgi.com> <Pine.LNX.4.64.0701101503310.22578@schroedinger.engr.sgi.com> <20070110230855.GF44411608@melbourne.sgi.com> <45A57333.6060904@yahoo.com.au> <20070111003158.GT33919298@melbourne.sgi.com> <45A58DFA.8050304@yahoo.com.au> <20070111012404.GW33919298@melbourne.sgi.com> <45A602F0.1090405@yahoo.com.au> <Pine.LNX.4.64.0701110950380.28802@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0701110950380.28802@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: David Chinner <dgc@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Thu, 11 Jan 2007, Nick Piggin wrote:
> 
> 
>>You're not turning on zone_reclaim, by any chance, are you?
> 
> 
> It is not a NUMA system so zone reclaim is not available.

Ah yes... Can't you force it on if you have a NUMA complied kernel?

> zone reclaim was 
> already in 2.6.16.

Well it was a long shot, but that is something that has had a few
changes recently and is something that could interact badly with
the global pdflush.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
