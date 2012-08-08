Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 32EB16B004D
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 10:52:48 -0400 (EDT)
Date: Wed, 8 Aug 2012 09:51:33 -0500 (CDT)
From: "Christoph Lameter (Open Source)" <cl@linux.com>
Subject: Re: Common10 [06/20] Extract a common function for
 kmem_cache_destroy
In-Reply-To: <CAAmzW4NVxsV2pOWYkrq0e7CSafafEq7QBsvD6Zh3ztuYzaLJSQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.02.1208080951230.7756@greybox.home>
References: <20120803192052.448575403@linux.com> <20120803192151.110627928@linux.com> <CAAmzW4NVxsV2pOWYkrq0e7CSafafEq7QBsvD6Zh3ztuYzaLJSQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Sun, 5 Aug 2012, JoonSoo Kim wrote:

> I suggest following modification.
> I thinks it is sufficient to prevent above mentioned case.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
