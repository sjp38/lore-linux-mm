Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id A18C46B005C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 13:29:05 -0400 (EDT)
Date: Thu, 14 Jun 2012 12:29:02 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 4/4] make CFLGS_OFF_SLAB visible for all slabs
In-Reply-To: <4FDA0ADB.2010508@parallels.com>
Message-ID: <alpine.DEB.2.00.1206141228230.12773@router.home>
References: <1339676244-27967-1-git-send-email-glommer@parallels.com> <1339676244-27967-5-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1206141019010.32075@router.home> <4FDA0ADB.2010508@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, devel@openvz.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Thu, 14 Jun 2012, Glauber Costa wrote:

> I want to mask that out in kmem-specific slab creation. Since I am copying the
> original flags, and that flag is embedded in the slab saved flags, it will be
> carried to the new slab if I don't mask it out.

I thought you intercepted slab creation? You can copy the flags at that
point.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
