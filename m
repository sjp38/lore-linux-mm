Date: Fri, 12 Aug 2005 19:28:23 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: Zoned CART
Message-ID: <20050812222823.GA11168@dmt.cnet>
References: <1123857429.14899.59.camel@twins> <20050812202104.GA8925@dmt.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050812202104.GA8925@dmt.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Rahul Iyer <rni@andrew.cmu.edu>
List-ID: <linux-mm.kvack.org>

> Note: this one dies horribly with highmem machines, probably due to 
> atomic allocation of nodes - an improvement would be to 

to preallocate memory required for the nodes and have a simple
allocator manage that space, or better use the hashtable.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
