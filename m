Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j1IFVbm3000415
	for <linux-mm@kvack.org>; Fri, 18 Feb 2005 10:31:37 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1IFVa8o232994
	for <linux-mm@kvack.org>; Fri, 18 Feb 2005 10:31:36 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j1IFVQVH028773
	for <linux-mm@kvack.org>; Fri, 18 Feb 2005 10:31:26 -0500
Subject: Re: [RFC][PATCH] Sparse Memory Handling (hot-add foundation)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050218051633.GA5037@w-mikek2.ibm.com>
References: <1108685033.6482.38.camel@localhost>
	 <20050218051633.GA5037@w-mikek2.ibm.com>
Content-Type: text/plain
Date: Fri, 18 Feb 2005 07:31:01 -0800
Message-Id: <1108740662.6482.53.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Kravetz <kravetz@us.ibm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-02-17 at 21:16 -0800, Mike Kravetz wrote:
> On Thu, Feb 17, 2005 at 04:03:53PM -0800, Dave Hansen wrote:
> > The attached patch
> 
> Just tried to compile this and noticed that there is no definition
> of valid_section_nr(),  referenced in sparse_init.

What's your .config?  I didn't actually try it on ppc64, and I may have
missed one of the necessary patches.  I trimmed it down to very near the
minimum set on x86.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
