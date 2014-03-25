Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 645166B003A
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 13:06:40 -0400 (EDT)
Received: by mail-ie0-f170.google.com with SMTP id rd18so694503iec.1
        for <linux-mm@kvack.org>; Tue, 25 Mar 2014 10:06:40 -0700 (PDT)
Received: from qmta02.emeryville.ca.mail.comcast.net (qmta02.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:24])
        by mx.google.com with ESMTP id pe7si20119426icc.42.2014.03.25.10.06.39
        for <linux-mm@kvack.org>;
        Tue, 25 Mar 2014 10:06:39 -0700 (PDT)
Date: Tue, 25 Mar 2014 12:06:36 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm: slub: gpf in deactivate_slab
In-Reply-To: <20140325165247.GA7519@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1403251205140.24534@nuc>
References: <53208A87.2040907@oracle.com> <5331A6C3.2000303@oracle.com> <20140325165247.GA7519@dhcp22.suse.cz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Sasha Levin <sasha.levin@oracle.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 25 Mar 2014, Michal Hocko wrote:

> You are right. The function even does VM_BUG_ON(!irqs_disabled())...
> Unfortunatelly we do not seem to have an _irq alternative of the bit
> spinlock.
> Not sure what to do about it. Christoph?
>
> Btw. it seems to go way back to 3.1 (1d07171c5e58e).

Well there is a preempt_enable() (bit_spin_lock) and a preempt_disable()
bit_spin_unlock() within a piece of code where irqs are disabled.

Is that a problem? Has been there for a long time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
