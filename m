Message-ID: <46952D0A.1090304@google.com>
Date: Wed, 11 Jul 2007 12:18:34 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/7] cpuset write dirty map
References: <465FB6CF.4090801@google.com> <Pine.LNX.4.64.0706041138410.24412@schroedinger.engr.sgi.com> <46646A33.6090107@google.com> <Pine.LNX.4.64.0706041250440.25535@schroedinger.engr.sgi.com> <468023CA.2090401@google.com> <Pine.LNX.4.64.0706261216110.20282@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706261216110.20282@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

throttle_vm_writeout() you added a clause that checks for __GFP_FS |
__GFP_IO and if they're not both set it calls blk_congestion_wait()
immediately and then returns, no change for looping. Two questions:

1. This seems like an unrelated bug fix. Should you submit it as a
standalone patch?

2. You put this gfp check before the check for get_dirty_limits. It's
possible that this will block even though without your change it would
have returned straight away. Would it better, instead of adding the
if-clause at the top of the function, to embed the gfp check at the end
of the for-loop after calling blk_congestion_wait?

	-- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
