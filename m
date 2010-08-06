Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1706C6B02A7
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 17:18:53 -0400 (EDT)
Date: Fri, 6 Aug 2010 17:17:26 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] GSoC 2010 - Memory hotplug support for Xen guests -
 second fully working version - once again
Message-ID: <20100806211726.GA18466@phenom.dumpdata.com>
References: <20100806111147.GA31683@router-fw-old.local.net-space.pl>
 <20100806163408.GA8678@phenom.dumpdata.com>
 <4C5C6067.1000403@goop.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C5C6067.1000403@goop.org>
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Daniel Kiper <dkiper@net-space.pl>, stefano.stabellini@eu.citrix.com, linux-mm@kvack.org, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, v.tolstov@selfip.ru
List-ID: <linux-mm.kvack.org>

> >Can you repost a patch that is on top of a virgin tree please?
> 
> I just thanked him for posting a delta ;)  I've pushed this into
> xen/memory-hotplug so you can easily generate a complete diff with
> "git diff v2.6.34..xen/memory-hotplug".

Ahh, I didn't know you had it in your tree already. Will use the git
diff for a more careful analysis.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
