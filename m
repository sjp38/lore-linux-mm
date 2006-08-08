Date: Tue, 8 Aug 2006 10:25:11 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.18-rc3-mm2: rcu radix tree patches break page migration
Message-Id: <20060808102511.64dcf5dc.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0608080918150.27507@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608071556530.23088@schroedinger.engr.sgi.com>
	<44D7E7DF.1080106@yahoo.com.au>
	<Pine.LNX.4.64.0608072041010.24071@schroedinger.engr.sgi.com>
	<44D82508.9020409@yahoo.com.au>
	<Pine.LNX.4.64.0608080918150.27507@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Aug 2006 09:19:08 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> The radix tree rcu code runs into trouble when we use radix_tree_lookup
> slot and use the slot to update the page reference.

"trouble"?  Do we know what it is?  What are the implications of this for
the rcu radix-tree patches?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
