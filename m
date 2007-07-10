Date: Tue, 10 Jul 2007 11:57:40 -0700
From: Bill Irwin <bill.irwin@oracle.com>
Subject: Re: [RFC][PATCH] hugetlbfs read support
Message-ID: <20070710185740.GB26380@holomorphy.com>
References: <1184009291.31638.8.camel@dyn9047017100.beaverton.ibm.com> <20070710153752.GV26380@holomorphy.com> <Pine.LNX.4.64.0707101152190.12299@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707101152190.12299@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Bill Irwin <bill.irwin@oracle.com>, Badari Pulavarty <pbadari@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>, nacc@us.ibm.com, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jul 2007, Bill Irwin wrote:
>> What's the testing status of all this? I thoroughly approve of the
>> concept, of course.

On Tue, Jul 10, 2007 at 11:53:08AM -0700, Christoph Lameter wrote:
> The status is that Andrew has doubts about the antifrag approach etc 
> which will stall all of this if the antifrag does not get merged. See 
> the mm-merge discussion on lkml. Please make noise. Andrew asked for it.

Not quite what I was asking about, but good to hear.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
