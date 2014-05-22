Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id CA8246B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 20:15:29 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id l6so4499467qcy.3
        for <linux-mm@kvack.org>; Wed, 21 May 2014 17:15:29 -0700 (PDT)
Received: from qmta06.emeryville.ca.mail.comcast.net (qmta06.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:56])
        by mx.google.com with ESMTP id w7si3332826qaj.53.2014.05.21.17.15.29
        for <linux-mm@kvack.org>;
        Wed, 21 May 2014 17:15:29 -0700 (PDT)
Date: Wed, 21 May 2014 19:15:26 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH RFC 3/3] slub: reparent memcg caches' slabs on memcg
 offline
In-Reply-To: <20140521151423.GC23193@esperanza>
Message-ID: <alpine.DEB.2.10.1405211913350.4433@gentwo.org>
References: <alpine.DEB.2.10.1405141119320.16512@gentwo.org> <20140515071650.GB32113@esperanza> <alpine.DEB.2.10.1405151015330.24665@gentwo.org> <20140516132234.GF32113@esperanza> <alpine.DEB.2.10.1405160957100.32249@gentwo.org> <20140519152437.GB25889@esperanza>
 <alpine.DEB.2.10.1405191056580.22956@gentwo.org> <537A4D27.1050909@parallels.com> <20140521135826.GA23193@esperanza> <alpine.DEB.2.10.1405210944140.8038@gentwo.org> <20140521151423.GC23193@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 21 May 2014, Vladimir Davydov wrote:

> Don't think so. AFAIU put_cpu_partial() first checks if the per-cpu
> partial list has more than s->cpu_partial objects draining it if so, but
> then it adds the newly frozen slab there anyway.

Hmmm... Ok true. Maybe insert some code there then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
