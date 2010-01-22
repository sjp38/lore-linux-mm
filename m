Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E1AA96B006A
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 09:43:37 -0500 (EST)
Date: Fri, 22 Jan 2010 08:43:32 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
In-Reply-To: <20100122001534.GB30417@ldl.fc.hp.com>
Message-ID: <alpine.DEB.2.00.1001220842340.2704@router.home>
References: <alpine.DEB.2.00.1001151730350.10558@router.home> <alpine.DEB.2.00.1001191252370.25101@router.home> <20100119200228.GE11010@ldl.fc.hp.com> <alpine.DEB.2.00.1001191427370.26683@router.home> <20100119212935.GG11010@ldl.fc.hp.com>
 <alpine.DEB.2.00.1001191545170.26683@router.home> <20100121214749.GJ17684@ldl.fc.hp.com> <alpine.DEB.2.00.1001211643020.20071@router.home> <20100121230551.GO17684@ldl.fc.hp.com> <alpine.DEB.2.00.1001211737360.20719@router.home>
 <20100122001534.GB30417@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alex Chiang <achiang@hp.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, penberg@cs.helsinki.fi, linux-ia64@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Jan 2010, Alex Chiang wrote:

> > Difficult since I also did not track how this belonged together. Sorry.
>
> Replying and cc'ing so akpm sees this as our final answer. :)

Well I think this is going through the git tree for slab allocators via
Pekka.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
