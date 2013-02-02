Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id D17086B000A
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 19:29:59 -0500 (EST)
Date: Fri, 1 Feb 2013 16:29:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 6/9] mm/page_alloc: add informative debugging message in
 page_outside_zone_boundaries()
Message-Id: <20130201162957.3ec618cf.akpm@linux-foundation.org>
In-Reply-To: <20130201162848.74bdb2a7.akpm@linux-foundation.org>
References: <1358463181-17956-1-git-send-email-cody@linux.vnet.ibm.com>
	<1358463181-17956-7-git-send-email-cody@linux.vnet.ibm.com>
	<20130201162848.74bdb2a7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>, Linux MM <linux-mm@kvack.org>, David Hansen <dave@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>

On Fri, 1 Feb 2013 16:28:48 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> > +	if (ret)
> > +		pr_debug("page %lu outside zone [ %lu - %lu ]\n",
> > +			pfn, start_pfn, start_pfn + sp);
> > +
> >  	return ret;
> >  }
> 
> As this condition leads to a VM_BUG_ON(), "pr_debug" seems rather wimpy
> and I doubt if we need to be concerned about flooding the console.
> 
> I'll switch it to pr_err.

otoh, as nobody has ever hit that VM_BUG_ON() (yes?), do we really need
the patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
