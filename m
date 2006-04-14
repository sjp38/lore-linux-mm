Message-Id: <4t16i2$m7o67@orsmga001.jf.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [RFD hugetlbfs] strict accounting and wasteful reservations
Date: Fri, 14 Apr 2006 10:40:13 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <1145036008.10795.122.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Adam Litke' <agl@us.ibm.com>
Cc: 'David Gibson' <david@gibson.dropbear.id.au>, akpm@osdl.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Adam Litke wrote on Friday, April 14, 2006 10:33 AM
> On Thu, 2006-04-13 at 18:55 -0700, Chen, Kenneth W wrote:
> > Arbitrary offset isn't that bad, here is the patch that I forward port to
> > 2.6.17-rc1.  It is just 35 lines more.  Another thing I can do is to put
> > the variable region tracking code into a library function, maybe that will
> > help to move it along?  I'm with Adam, I don't like to see hugetlbfs have
> > yet another uncommon behavior.
> 
> Thanks Ken.  The patch passes the libhugetlbfs test suite and also works
> as advertised for sparse mappings.  I don't recall, is this the version
> you and David were converging on before Dave's patch was merged?  I seem
> to remember a few iterations of this patch centered locking discussions,
> etc.


Adam, yes, this is the latest rev includes all the comments from David.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
