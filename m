Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j95HKBKL016621
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 13:20:11 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j95HL7fK521786
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 11:21:07 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j95HL7nx015346
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 11:21:07 -0600
Subject: Re: [PATCH 5/7] Fragmentation Avoidance V16: 005_fallback
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0510051815370.16421@skynet>
References: <20051005144546.11796.1154.sendpatchset@skynet.csn.ul.ie>
	 <20051005144612.11796.35309.sendpatchset@skynet.csn.ul.ie>
	 <1128531115.26009.32.camel@localhost>
	 <Pine.LNX.4.58.0510051815370.16421@skynet>
Content-Type: text/plain
Date: Wed, 05 Oct 2005 10:20:59 -0700
Message-Id: <1128532859.26009.41.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, jschopp@austin.ibm.com, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-10-05 at 18:16 +0100, Mel Gorman wrote:
> 
> +               reserve_type=RCLM_NORCLM;
> 
> (Ignore the whitespace damage, cutting and pasting just so you can see
> it)

Sorry, should have been more specific.  You need spaces around the '='.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
