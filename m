Subject: Re: Atomic operation for physically moving a page
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <200406190103.i5J13WWr010687@turing-police.cc.vt.edu>
References: <20040619003712.35865.qmail@web10904.mail.yahoo.com>
	 <200406190103.i5J13WWr010687@turing-police.cc.vt.edu>
Content-Type: text/plain
Message-Id: <1087613632.4921.32.camel@nighthawk>
Mime-Version: 1.0
Date: Fri, 18 Jun 2004 19:53:52 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Ashwin Rao <ashwin_s_rao@yahoo.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2004-06-18 at 18:03, Valdis.Kletnieks@vt.edu wrote:
> On Fri, 18 Jun 2004 17:37:12 PDT, Ashwin Rao <ashwin_s_rao@yahoo.com>  said:
> > I want to copy a page from one physical location to
> > another (taking the appr. locks).
> 
> At the risk of sounding stupid, what problem are you trying to solve by copying
> a page? Not only (as you note) could the page be referenced by multiple
> processes, it could (conceivably) belong to a kernel slab or something, or be a
> buffer for an in-flight I/O request, or any number of other possibly-racy
> situations.

You also have to make sure that the page is something who's physical
address is allowed to change.  Some stuff like DMA buffers, or a part of
a hugetlb page might not even be valid to move.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
