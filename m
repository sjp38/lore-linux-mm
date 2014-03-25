Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id BE2476B004D
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 14:10:58 -0400 (EDT)
Received: by mail-ob0-f177.google.com with SMTP id wo20so992268obc.22
        for <linux-mm@kvack.org>; Tue, 25 Mar 2014 11:10:58 -0700 (PDT)
Received: from qmta05.emeryville.ca.mail.comcast.net (qmta05.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:48])
        by mx.google.com with ESMTP id eh9si18081177oeb.136.2014.03.25.11.10.57
        for <linux-mm@kvack.org>;
        Tue, 25 Mar 2014 11:10:58 -0700 (PDT)
Date: Tue, 25 Mar 2014 13:10:55 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm: slub: gpf in deactivate_slab
In-Reply-To: <5331B9C8.7080106@oracle.com>
Message-ID: <alpine.DEB.2.10.1403251308590.26471@nuc>
References: <53208A87.2040907@oracle.com> <5331A6C3.2000303@oracle.com> <20140325165247.GA7519@dhcp22.suse.cz> <alpine.DEB.2.10.1403251205140.24534@nuc> <5331B9C8.7080106@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 25 Mar 2014, Sasha Levin wrote:

> So here's the full trace. There's obviously something wrong here since we
> pagefault inside the section that was supposed to be running with irqs
> disabled
> and I don't see another cause besides this.
>
> The unreliable entries in the stack trace also somewhat suggest that the
> fault is with the code I've pointed out.

Looks like there was some invalid data fed to the function and the page
fault with interrupts disabled is the result of following and invalid
pointer.

Is there more context information available? What are the options set for
the cache that the operation was performed on?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
