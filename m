Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 229F86B0044
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 11:55:40 -0400 (EDT)
Date: Fri, 27 Jul 2012 10:55:37 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Any reason to use put_page in slub.c?
In-Reply-To: <1343391586-18837-1-git-send-email-glommer@parallels.com>
Message-ID: <alpine.DEB.2.00.1207271054230.18371@router.home>
References: <1343391586-18837-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 27 Jul 2012, Glauber Costa wrote:

> But I am still wondering if there is anything I am overlooking.

put_page() is necessary because other subsystems may still be holding a
refcount on the page (if f.e. there is DMA still pending to that page).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
