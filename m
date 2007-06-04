Date: Mon, 4 Jun 2007 12:52:11 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 1/7] cpuset write dirty map
In-Reply-To: <46646A33.6090107@google.com>
Message-ID: <Pine.LNX.4.64.0706041250440.25535@schroedinger.engr.sgi.com>
References: <465FB6CF.4090801@google.com> <Pine.LNX.4.64.0706041138410.24412@schroedinger.engr.sgi.com>
 <46646A33.6090107@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ethan Solomita <solo@google.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@google.com>, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

On Mon, 4 Jun 2007, Ethan Solomita wrote:

> > You should preserve my Signed-off-by: since I wrote most of this. Is there 
> > a changelog?
> > 
> 
> 	I wasn't sure of the etiquette -- I'd thought that by saying you had
> signed it off that meant you were accepting my modifications, and didn't
> want to presume. But I will change it if you like. No slight intended.
> 
> 	Unfortunately I don't have a changelog, and since I've since forward
> ported the changes it would be hard to produce. If you want to review it
> you should probably review it all, because the forward porting may have
> introduced issues.

I glanced over it and it looks okay. Please cc me on future submissions.

What testing was done? Would you include the results of tests in your next 
post?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
