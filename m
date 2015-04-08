Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1D85F6B006E
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 14:24:29 -0400 (EDT)
Received: by iggg4 with SMTP id g4so47288217igg.0
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 11:24:28 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id dz5si189135icb.102.2015.04.08.11.24.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 08 Apr 2015 11:24:28 -0700 (PDT)
Date: Wed, 8 Apr 2015 13:24:26 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm] slab: use cgroup ino for naming per memcg caches
In-Reply-To: <20150408181911.GA18199@esperanza>
Message-ID: <alpine.DEB.2.11.1504081323390.20694@gentwo.org>
References: <1428414798-12932-1-git-send-email-vdavydov@parallels.com> <20150407133819.993be7a53a3aa16311aba1f5@linux-foundation.org> <20150408095404.GC10286@esperanza> <alpine.DEB.2.11.1504080845200.13120@gentwo.org> <20150408181911.GA18199@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 8 Apr 2015, Vladimir Davydov wrote:

> Yeah, I think cache merging is a good argument for grouping memcg caches
> under /sys/kernel/slab/<slab-name>/cgroup/. We cannot maintain symlinks
> for merged memcg caches, because when a memcg cache is created we do not
> have names of caches the new cache is merged with. If memcg caches were
> listed under /sys/kernel/slab/ along with global ones, absence of the
> symlinks would lead to confusion.

The point of the unique name creation is to not have to use the name given
by the user for the slab. You can generate a unique identifier and use
that as a target for the symlink.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
