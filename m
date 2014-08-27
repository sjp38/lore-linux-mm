Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7A7A66B0038
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 11:25:27 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so480829pad.11
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 08:25:27 -0700 (PDT)
Received: from qmta08.emeryville.ca.mail.comcast.net (qmta08.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:80])
        by mx.google.com with ESMTP id mk5si1167460pab.95.2014.08.27.08.25.11
        for <linux-mm@kvack.org>;
        Wed, 27 Aug 2014 08:25:11 -0700 (PDT)
Date: Wed, 27 Aug 2014 10:25:08 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm, slub: do not add duplicate sysfs
In-Reply-To: <1409152488-21227-1-git-send-email-chaowang@redhat.com>
Message-ID: <alpine.DEB.2.11.1408271023130.17080@gentwo.org>
References: <1409152488-21227-1-git-send-email-chaowang@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: WANG Chao <chaowang@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "open list:SLAB ALLOCATOR" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>

On Wed, 27 Aug 2014, WANG Chao wrote:

> Mergeable slab can be changed to unmergeable after tuning its sysfs
> interface, for example echo 1 > trace. But the sysfs kobject with the unique
> name will be still there.

Hmmm... Merging should be switched off if any debugging features are
enabled. Maybe we need to disable modifying debug options for an active
cache? This could cause other issues as well since the debug options will
then apply to multiple caches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
