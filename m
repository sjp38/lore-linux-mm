Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9778E6B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 10:07:11 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id pv20so2670876lab.36
        for <linux-mm@kvack.org>; Thu, 22 May 2014 07:07:11 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id a8si13511174lbp.25.2014.05.22.07.07.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 May 2014 07:07:10 -0700 (PDT)
Date: Thu, 22 May 2014 18:07:00 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH RFC 3/3] slub: reparent memcg caches' slabs on memcg
 offline
Message-ID: <20140522140658.GB3147@esperanza>
References: <alpine.DEB.2.10.1405151015330.24665@gentwo.org>
 <20140516132234.GF32113@esperanza>
 <alpine.DEB.2.10.1405160957100.32249@gentwo.org>
 <20140519152437.GB25889@esperanza>
 <alpine.DEB.2.10.1405191056580.22956@gentwo.org>
 <537A4D27.1050909@parallels.com>
 <20140521135826.GA23193@esperanza>
 <alpine.DEB.2.10.1405210944140.8038@gentwo.org>
 <20140521151423.GC23193@esperanza>
 <alpine.DEB.2.10.1405211913350.4433@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1405211913350.4433@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 21, 2014 at 07:15:26PM -0500, Christoph Lameter wrote:
> On Wed, 21 May 2014, Vladimir Davydov wrote:
> 
> > Don't think so. AFAIU put_cpu_partial() first checks if the per-cpu
> > partial list has more than s->cpu_partial objects draining it if so, but
> > then it adds the newly frozen slab there anyway.
> 
> Hmmm... Ok true. Maybe insert some code there then.

Agree, it's better to add the check to put_cpu_partial() rather than to
__slab_free(), because the latter is a hot path.

I'll send the patches soon.

Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
