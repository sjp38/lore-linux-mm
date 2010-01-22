Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 328396B0071
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 11:37:26 -0500 (EST)
Message-ID: <4B59D42F.5030104@cs.helsinki.fi>
Date: Fri, 22 Jan 2010 18:37:03 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
References: <alpine.DEB.2.00.1001151730350.10558@router.home> <alpine.DEB.2.00.1001191252370.25101@router.home> <20100119200228.GE11010@ldl.fc.hp.com> <alpine.DEB.2.00.1001191427370.26683@router.home> <20100119212935.GG11010@ldl.fc.hp.com> <alpine.DEB.2.00.1001191545170.26683@router.home> <20100121214749.GJ17684@ldl.fc.hp.com> <alpine.DEB.2.00.1001211643020.20071@router.home> <20100121230551.GO17684@ldl.fc.hp.com> <alpine.DEB.2.00.1001211737360.20719@router.home> <20100122001534.GB30417@ldl.fc.hp.com> <alpine.DEB.2.00.1001220842340.2704@router.home>
In-Reply-To: <alpine.DEB.2.00.1001220842340.2704@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Alex Chiang <achiang@hp.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Thu, 21 Jan 2010, Alex Chiang wrote:
> 
>>> Difficult since I also did not track how this belonged together. Sorry.
>> Replying and cc'ing so akpm sees this as our final answer. :)
> 
> Well I think this is going through the git tree for slab allocators via
> Pekka.

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
