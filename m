Received: from e33.co.us.ibm.com ([9.17.249.43])
	by pokfb.esmtp.ibm.com (8.12.11/8.12.11) with ESMTP id j95GsNu6013003
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 12:54:24 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j95GqSKV005896
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 12:52:28 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j95Gs3fK533166
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 10:54:03 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j95Gs2GG005553
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 10:54:03 -0600
Subject: Re: [PATCH 5/7] Fragmentation Avoidance V16: 005_fallback
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20051005144612.11796.35309.sendpatchset@skynet.csn.ul.ie>
References: <20051005144546.11796.1154.sendpatchset@skynet.csn.ul.ie>
	 <20051005144612.11796.35309.sendpatchset@skynet.csn.ul.ie>
Content-Type: text/plain
Date: Wed, 05 Oct 2005 09:53:55 -0700
Message-Id: <1128531235.26009.35.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, jschopp@austin.ibm.com, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-10-05 at 15:46 +0100, Mel Gorman wrote:
> +static struct page *
> +fallback_alloc(int alloctype, struct zone *zone, unsigned int order)
> {
...
> +       /*
> +        * Here, the alloc type lists has been depleted as well as the global
> +        * pool, so fallback. When falling back, the largest possible block
> +        * will be taken to keep the fallbacks clustered if possible
> +        */
> +       while ((alloctype = *(++fallback_list)) != -1) {

That's a bit obtuse.  Is there no way to simplify it?  Just keeping an
index instead of a fallback_list pointer should make it quite a bit
easier to grok.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
