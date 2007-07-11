Date: Wed, 11 Jul 2007 13:11:48 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 1/7] cpuset write dirty map
In-Reply-To: <46952D0A.1090304@google.com>
Message-ID: <Pine.LNX.4.64.0707111311040.18429@schroedinger.engr.sgi.com>
References: <465FB6CF.4090801@google.com> <Pine.LNX.4.64.0706041138410.24412@schroedinger.engr.sgi.com>
 <46646A33.6090107@google.com> <Pine.LNX.4.64.0706041250440.25535@schroedinger.engr.sgi.com>
 <468023CA.2090401@google.com> <Pine.LNX.4.64.0706261216110.20282@schroedinger.engr.sgi.com>
 <46952D0A.1090304@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ethan Solomita <solo@google.com>
Cc: Andrew Morton <akpm@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jul 2007, Ethan Solomita wrote:

> 	Christoph -- I have a question about one part of the patches. In
> throttle_vm_writeout() you added a clause that checks for __GFP_FS |
> __GFP_IO and if they're not both set it calls blk_congestion_wait()
> immediately and then returns, no change for looping. Two questions:
> 
> 1. This seems like an unrelated bug fix. Should you submit it as a
> standalone patch?

This may be a leftover from earlier times when the logic was different in 
throttle vm writeout? 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
