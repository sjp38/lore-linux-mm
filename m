Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id A1C946B004D
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 11:41:45 -0400 (EDT)
Date: Wed, 8 Aug 2012 10:40:26 -0500 (CDT)
From: "Christoph Lameter (Open Source)" <cl@linux.com>
Subject: Re: Common10 [11/20] Do slab aliasing call from common code
In-Reply-To: <CAAmzW4P4aH5yvVjfboQN-+0-WG0=93LkwdmrS7yE9GQ5C=Uxdg@mail.gmail.com>
Message-ID: <alpine.DEB.2.02.1208081039460.7756@greybox.home>
References: <20120803192052.448575403@linux.com> <20120803192154.205306565@linux.com> <CAAmzW4P4aH5yvVjfboQN-+0-WG0=93LkwdmrS7yE9GQ5C=Uxdg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Sun, 5 Aug 2012, JoonSoo Kim wrote:

> sysfs_slab_alias() in __kmem_cache_alias() stores reference of name param.
> Currently, when we call __kmem_cache_alias(), we don't do kstrdup().
> It is not desired behavior as we don't want to be depend on caller of
> kmem_cache_create().
> So we need to do kstrdup() before invoking __kmem_cache_alias().

Ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
