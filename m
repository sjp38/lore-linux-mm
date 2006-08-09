Message-ID: <44D93CD0.5070905@yahoo.com.au>
Date: Wed, 09 Aug 2006 11:39:28 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: 2.6.18-rc3-mm2: rcu radix tree patches break page migration
References: <Pine.LNX.4.64.0608071556530.23088@schroedinger.engr.sgi.com>	<44D7E7DF.1080106@yahoo.com.au>	<Pine.LNX.4.64.0608072041010.24071@schroedinger.engr.sgi.com>	<44D82508.9020409@yahoo.com.au>	<Pine.LNX.4.64.0608080918150.27507@schroedinger.engr.sgi.com> <20060808102511.64dcf5dc.akpm@osdl.org>
In-Reply-To: <20060808102511.64dcf5dc.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

>On Tue, 8 Aug 2006 09:19:08 -0700 (PDT)
>Christoph Lameter <clameter@sgi.com> wrote:
>
>
>>The radix tree rcu code runs into trouble when we use radix_tree_lookup
>>slot and use the slot to update the page reference.
>>
>
>"trouble"?  Do we know what it is?  What are the implications of this for
>the rcu radix-tree patches?
>

I must have broken lookup_slot (luckily regular pagecache ops are not
affected). I'm looking at it...

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
