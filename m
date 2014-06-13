Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6CF866B0031
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 12:54:15 -0400 (EDT)
Received: by mail-qc0-f176.google.com with SMTP id w7so3166442qcr.21
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 09:54:15 -0700 (PDT)
Received: from qmta03.emeryville.ca.mail.comcast.net (qmta03.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:32])
        by mx.google.com with ESMTP id e10si5172046qai.96.2014.06.13.09.54.14
        for <linux-mm@kvack.org>;
        Fri, 13 Jun 2014 09:54:14 -0700 (PDT)
Date: Fri, 13 Jun 2014 11:54:11 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH -mm v3 7/8] slub: make dead memcg caches discard free
 slabs immediately
In-Reply-To: <d4608a7a00080a51740d747703af5462f1255176.1402602126.git.vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.10.1406131153520.913@gentwo.org>
References: <cover.1402602126.git.vdavydov@parallels.com> <d4608a7a00080a51740d747703af5462f1255176.1402602126.git.vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 13 Jun 2014, Vladimir Davydov wrote:

> Since a dead memcg cache is destroyed only after the last slab allocated
> to it is freed, we must disable caching of empty slabs for such caches,
> otherwise they will be hanging around forever.

Looks good and clean.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
