Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 063566B00C3
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 07:05:48 -0400 (EDT)
Received: by obcva7 with SMTP id va7so7492994obc.14
        for <linux-mm@kvack.org>; Tue, 02 Oct 2012 04:05:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1349170840.10698.14.camel@jlt4.sipsolutions.net>
References: <1349170840.10698.14.camel@jlt4.sipsolutions.net>
Date: Tue, 2 Oct 2012 20:05:48 +0900
Message-ID: <CAAmzW4OvWVfHhqs3puzArvVoNp4ZopZXdc38RVmFBkMd_LjNWA@mail.gmail.com>
Subject: Re: slab vs. slub kmem cache name inconsistency
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Berg <johannes@sipsolutions.net>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

Hi, Johannes.

2012/10/2 Johannes Berg <johannes@sipsolutions.net>:
> Hi,
>
> I just noticed that slub's kmem_cache_create() will kstrdup() the name,
> while slab doesn't. That's a little confusing, since when you look at
> slub you can easily get away with passing a string you built on the
> stack, while that will then lead to very strange results (and possibly
> crashes?) with slab.

As far as I know, this issue is already fixed. However, fix for this
is not merged into mainline yet.
You can find the fix in common_for_cgroups branch of Pekka's git tree.

git://git.kernel.org/pub/scm/linux/kernel/git/penberg/linux.git
slab/common-for-cgroups

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
