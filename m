Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1331D6B0035
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 10:20:26 -0400 (EDT)
Received: by mail-qg0-f41.google.com with SMTP id i50so4800970qgf.14
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 07:20:25 -0700 (PDT)
Received: from qmta08.emeryville.ca.mail.comcast.net (qmta08.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:80])
        by mx.google.com with ESMTP id o19si33691704qae.2.2014.07.02.07.20.23
        for <linux-mm@kvack.org>;
        Wed, 02 Jul 2014 07:20:25 -0700 (PDT)
Date: Wed, 2 Jul 2014 09:20:20 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: mm: slub: invalid memory access in setup_object
In-Reply-To: <20140702020454.GA6961@richard>
Message-ID: <alpine.DEB.2.11.1407020918130.17773@gentwo.org>
References: <53AAFDF7.2010607@oracle.com> <alpine.DEB.2.11.1406251228130.29216@gentwo.org> <alpine.DEB.2.02.1406301500410.13545@chino.kir.corp.google.com> <alpine.DEB.2.11.1407010956470.5353@gentwo.org> <20140702020454.GA6961@richard>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Cc: David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Wed, 2 Jul 2014, Wei Yang wrote:

> My patch is somewhat convoluted since I wanted to preserve the original logic
> and make minimal change. And yes, it looks not that nice to audience.

Well I was the author of the initial "convoluted" logic.

> I feel a little hurt by this patch. What I found and worked is gone with this
> patch.

Ok how about giving this one additional revision. Maybe you can make the
function even easier to read? F.e. the setting of the NULL pointer at the
end of the loop is ugly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
