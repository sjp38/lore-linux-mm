Date: Wed, 3 Oct 2007 10:46:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/6] cpuset write throttle
In-Reply-To: <4702E49D.2030206@google.com>
Message-ID: <Pine.LNX.4.64.0710031045290.3525@schroedinger.engr.sgi.com>
References: <469D3342.3080405@google.com> <46E741B1.4030100@google.com>
 <46E7434F.9040506@google.com> <20070914161517.5ea3847f.akpm@linux-foundation.org>
 <4702E49D.2030206@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ethan Solomita <solo@google.com>
Cc: a.p.zijlstra@chello.nl, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2 Oct 2007, Ethan Solomita wrote:

> 	Unfortunately this eliminates one of the main reasons for the
> per-cpuset throttling. If one cpuset is responsible for pushing one
> disk/BDI to its dirty limit, someone in another cpuset can get throttled.

I think that is acceptable. All processes that write to one disk/BDI must 
be affected by congestion on that device. We may have to deal with 
fairness issues later if it indeed becomes a problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
