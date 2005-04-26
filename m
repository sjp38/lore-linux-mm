Message-ID: <426DE4ED.8020006@yahoo.com.au>
Date: Tue, 26 Apr 2005 16:51:25 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH]: VM 4/8 dont-rotate-active-list
References: <16994.40620.892220.121182@gargle.gargle.HOWL> <20050425205141.0b756263.akpm@osdl.org>
In-Reply-To: <20050425205141.0b756263.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nikita Danilov <nikita@clusterfs.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> 
> I'll plop this into -mm to see what happens.  That should give us decent
> stability testing, but someone is going to have to do a ton of performance
> testing to justify an upstream merge, please.
> 

I did find that it helped swapping performance, fairly
significantly when I last tested it.

Having it in -mm for a while would be good.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
