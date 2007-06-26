Date: Tue, 26 Jun 2007 12:16:50 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 1/7] cpuset write dirty map
In-Reply-To: <468023CA.2090401@google.com>
Message-ID: <Pine.LNX.4.64.0706261216110.20282@schroedinger.engr.sgi.com>
References: <465FB6CF.4090801@google.com> <Pine.LNX.4.64.0706041138410.24412@schroedinger.engr.sgi.com>
 <46646A33.6090107@google.com> <Pine.LNX.4.64.0706041250440.25535@schroedinger.engr.sgi.com>
 <468023CA.2090401@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@google.com>
Cc: Ethan Solomita <solo@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

On Mon, 25 Jun 2007, Ethan Solomita wrote:

> 	The effect of this patchset is straightforward. Without it there are
> long hangs between appearances of the date. With it the dates are all 5
> (or sometimes 6) seconds apart.
> 
> 	I also added printks to the kernel to verify that, without these
> patches, the tee was being throttled (along with lots of other things),
> and with the patch only pdflush is being throttled.

That sounds good. Andrew: Any chance that we can get this patchset merged?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
