Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id B31786B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 14:10:25 -0400 (EDT)
Date: Wed, 30 May 2012 13:10:22 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common 06/22] Extract common fields from struct kmem_cache
In-Reply-To: <alpine.DEB.2.00.1205301028330.28968@router.home>
Message-ID: <alpine.DEB.2.00.1205301309520.31768@router.home>
References: <20120523203433.340661918@linux.com> <20120523203508.434967564@linux.com> <CAOJsxLGHZjucZUi=K3V6QDgP-UqA2GQY=z7D8poKMTO-JETZ2g@mail.gmail.com> <alpine.DEB.2.00.1205301028330.28968@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.00.1205301309522.31768@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

Tried using an anonymous struct but these are not supported in the kernel
it seems. C11 supports it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
