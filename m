Date: Thu, 11 Jan 2007 09:51:15 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [REGRESSION] 2.6.19/2.6.20-rc3 buffered write slowdown
In-Reply-To: <45A602F0.1090405@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0701110950380.28802@schroedinger.engr.sgi.com>
References: <20070110223731.GC44411608@melbourne.sgi.com>
 <Pine.LNX.4.64.0701101503310.22578@schroedinger.engr.sgi.com>
 <20070110230855.GF44411608@melbourne.sgi.com> <45A57333.6060904@yahoo.com.au>
 <20070111003158.GT33919298@melbourne.sgi.com> <45A58DFA.8050304@yahoo.com.au>
 <20070111012404.GW33919298@melbourne.sgi.com> <45A602F0.1090405@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: David Chinner <dgc@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Jan 2007, Nick Piggin wrote:

> You're not turning on zone_reclaim, by any chance, are you?

It is not a NUMA system so zone reclaim is not available. zone reclaim was 
already in 2.6.16.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
