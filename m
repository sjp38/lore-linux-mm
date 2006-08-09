Date: Wed, 9 Aug 2006 10:33:26 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [1/3] Add __GFP_THISNODE to avoid fallback to other nodes and
 ignore cpuset/memory policy restrictions.
In-Reply-To: <20060808133533.673edc84.pj@sgi.com>
Message-ID: <Pine.LNX.4.64.0608091031540.15699@skynet.skynet.ie>
References: <Pine.LNX.4.64.0608080930380.27620@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0608081748070.24142@skynet.skynet.ie>
 <Pine.LNX.4.64.0608081001220.27866@schroedinger.engr.sgi.com>
 <20060808104752.3e7052dd.pj@sgi.com> <Pine.LNX.4.64.0608081052460.28259@schroedinger.engr.sgi.com>
 <20060808111855.531e4e29.pj@sgi.com> <Pine.LNX.4.64.0608081142130.29355@schroedinger.engr.sgi.com>
 <20060808133533.673edc84.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Paul Jackson <pj@sgi.com>, akpm@osdl.org, Linux Memory Management List <linux-mm@kvack.org>, jes@sgi.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Aug 2006, Paul Jackson wrote:

>> Sure. Some examples
>
> Hmmm ... more than I realized.
>
> These __GFP_THISNODE patches seem reasonable to me.
>

I'm happy enough as well. Thanks for taking the time to explain all of the 
flags potential users.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
