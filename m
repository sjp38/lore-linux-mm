Message-ID: <45FBECCF.6020106@shadowen.org>
Date: Sat, 17 Mar 2007 13:27:43 +0000
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] Lumpy Reclaim V5
References: <exportbomb.1173723760@pinky> <20070315192038.82933a2f.akpm@linux-foundation.org>
In-Reply-To: <20070315192038.82933a2f.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Mon, 12 Mar 2007 18:22:45 +0000 Andy Whitcroft <apw@shadowen.org> wrote:
> 
>> Following this email are three patches which represent the
>> current state of the lumpy reclaim patches; collectively lumpy V5.
> 
> So where do we stand with this now?    Does it make anything get better?

I am still working to fairly compare the various combinations.  One of
the problems is that if you push any reclaim algorithm to its physical
limits you will get the same overall success rates.

I think there is still some work to do refining lumpy, and reclaim in
general.  But I feel what we have now is pretty solid base for that.

> I (continue to) think that if this is to be truly useful, we need some way
> of using it from kswapd to keep a certain minimum number of order-1,
> order-2, etc pages in the freelists.

I think this is a key component of the mix and am just starting to play
with this.  I hope that this can provide improvements in the
instantaneous availability of these higher orders and improve average
latency.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
