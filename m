Date: Fri, 14 Sep 2007 13:16:51 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/4] hugetlb: interleave dequeueing of huge pages
In-Reply-To: <1189800591.5315.69.camel@localhost>
Message-ID: <Pine.LNX.4.64.0709141315510.22157@schroedinger.engr.sgi.com>
References: <20070906182134.GA7779@us.ibm.com>  <20070906182430.GB7779@us.ibm.com>
 <20070906182704.GC7779@us.ibm.com>  <Pine.LNX.4.64.0709141153360.17038@schroedinger.engr.sgi.com>
  <1189796638.5315.50.camel@localhost>  <Pine.LNX.4.64.0709141241050.17369@schroedinger.engr.sgi.com>
 <1189800591.5315.69.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, wli@holomorphy.com, agl@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 14 Sep 2007, Lee Schermerhorn wrote:

> Yeah, I mistyped...  But, nid IS private to that function.  This is a
> valid use of static.  But, perhaps it could use a comment to call
> attention to it.

I think its best to move nis outside of the function and give it a longer 
name that is distinctive from names we use for local variables. F.e.

last_allocated_node

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
