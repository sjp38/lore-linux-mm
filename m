Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 46AA36B0081
	for <linux-mm@kvack.org>; Mon, 21 May 2012 12:23:08 -0400 (EDT)
Date: Mon, 21 May 2012 11:23:04 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH] hugetlb: fix resv_map leak in error path
In-Reply-To: <20120521142822.GF28631@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1205211122360.30649@router.home>
References: <20120518184630.FF3307BD@kernel> <20120521142822.GF28631@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com, kosaki.motohiro@jp.fujitsu.com, hughd@google.com, rientjes@google.com, adobriyan@gmail.com, akpm@linux-foundation.org

On Mon, 21 May 2012, Mel Gorman wrote:

> > Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
>
> Acked-by: Mel Gorman <mel@csn.ul.ie>

Reported/tested-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
