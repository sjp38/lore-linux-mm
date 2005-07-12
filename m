Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j6C5P48M014486
	for <linux-mm@kvack.org>; Tue, 12 Jul 2005 01:25:04 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j6C5P4wY234010
	for <linux-mm@kvack.org>; Tue, 12 Jul 2005 01:25:04 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j6C5P4mk008674
	for <linux-mm@kvack.org>; Tue, 12 Jul 2005 01:25:04 -0400
Subject: Re: [Fwd: [PATCH 2/4] cpusets new __GFP_HARDWALL flag]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050711195540.681182d0.pj@sgi.com>
References: <1121101013.15095.19.camel@localhost>
	 <42D2AE0F.8020809@austin.ibm.com>  <20050711195540.681182d0.pj@sgi.com>
Content-Type: text/plain
Date: Mon, 11 Jul 2005 22:24:55 -0700
Message-Id: <1121145895.5446.1.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Joel Schopp <jschopp@austin.ibm.com>, linux-mm <linux-mm@kvack.org>, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Mon, 2005-07-11 at 19:55 -0700, Paul Jackson wrote:
> One question.  I've not actually read the memory fragmentation
> avoidance patch, so this might be a stupid question.  That
> notwithstanding, do you really need two flags, one KERN and one USER?
> Or would one flag be sufficient - to mark USER pages.  Unmarked pages
> would be KERN, presumably.  One really only needs 2 bits if one has
> 3 or 4 states to track -- if that's the case, it's not clear to me
> what those 3 or 4 states are (maybe if I actually read the patch it
> would be clear ;).

There are four types, but it only consumes two GFP bits.  It's correctly
packed.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
