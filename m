Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7D40F6B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 09:47:45 -0400 (EDT)
Received: by mail-la0-f53.google.com with SMTP id ty20so1074919lab.26
        for <linux-mm@kvack.org>; Thu, 22 May 2014 06:47:44 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id xb4si13379445lbb.4.2014.05.22.06.47.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 May 2014 06:47:43 -0700 (PDT)
Date: Thu, 22 May 2014 17:47:28 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH RFC 3/3] slub: reparent memcg caches' slabs on memcg
 offline
Message-ID: <20140522134726.GA3147@esperanza>
References: <20140515071650.GB32113@esperanza>
 <alpine.DEB.2.10.1405151015330.24665@gentwo.org>
 <20140516132234.GF32113@esperanza>
 <alpine.DEB.2.10.1405160957100.32249@gentwo.org>
 <20140519152437.GB25889@esperanza>
 <alpine.DEB.2.10.1405191056580.22956@gentwo.org>
 <537A4D27.1050909@parallels.com>
 <alpine.DEB.2.10.1405210937440.8038@gentwo.org>
 <20140521150408.GB23193@esperanza>
 <alpine.DEB.2.10.1405211912400.4433@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1405211912400.4433@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 21, 2014 at 07:13:21PM -0500, Christoph Lameter wrote:
> On Wed, 21 May 2014, Vladimir Davydov wrote:
> 
> > Do I understand you correctly that the following change looks OK to you?
> 
> Almost. Preemption needs to be enabled before functions that invoke the
> page allocator etc etc.

I need to disable preemption only in slab_free, which never blocks
according to its semantics, so everything should be fine just like that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
