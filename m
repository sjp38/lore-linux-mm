Date: Thu, 16 Dec 2004 16:13:23 +1100
From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH 0/3] NUMA boot hash allocation interleaving
Message-ID: <20041216051323.GI24000@krispykreme.ozlabs.ibm.com>
References: <Pine.SGI.4.61.0412141720420.22462@kzerza.americas.sgi.com> <50260000.1103061628@flay> <20041215045855.GH27225@wotan.suse.de> <20041215144730.GC24000@krispykreme.ozlabs.ibm.com> <20041216050248.GG32718@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041216050248.GG32718@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, Brent Casavant <bcasavan@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, jrsantos@austin.ibm.com
List-ID: <linux-mm.kvack.org>

 
> I asked Brent to run some benchmarks originally and I believe he has 
> already run all that he could easily set up. If you want more testing
> you'll need to test yourself I think. 

We will be testing it.

> At least I don't think this patch should be further stalled unless
> someone actually comes up with a proof that it actually affects
> performance.

I was more concerned about the idea of removing the opt-in part of the
patch. If it ends up being a negative for ppc64 it would be nice to have
a way to turn it off.

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
