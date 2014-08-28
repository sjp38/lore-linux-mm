Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 15DB86B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 23:42:49 -0400 (EDT)
Received: by mail-qa0-f49.google.com with SMTP id i13so203244qae.8
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 20:42:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m8si3997064qas.49.2014.08.27.20.42.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Aug 2014 20:42:48 -0700 (PDT)
Date: Thu, 28 Aug 2014 11:42:45 +0800
From: WANG Chao <chaowang@redhat.com>
Subject: Re: [PATCH] mm, slub: do not add duplicate sysfs
Message-ID: <20140828034245.GC3971@dhcp-17-37.nay.redhat.com>
References: <1409152488-21227-1-git-send-email-chaowang@redhat.com>
 <alpine.DEB.2.11.1408271023130.17080@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1408271023130.17080@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "open list:SLAB ALLOCATOR" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>

On 08/27/14 at 10:25am, Christoph Lameter wrote:
> On Wed, 27 Aug 2014, WANG Chao wrote:
> 
> > Mergeable slab can be changed to unmergeable after tuning its sysfs
> > interface, for example echo 1 > trace. But the sysfs kobject with the unique
> > name will be still there.
> 
> Hmmm... Merging should be switched off if any debugging features are
> enabled. Maybe we need to disable modifying debug options for an active
> cache? This could cause other issues as well since the debug options will
> then apply to multiple caches.

Yes, currently merging is already switched off if there's any debug flag.

It sounds a bit overkill to me to disable runtime configuration. I don't
know how many people out there would trace a mergeable (multiple)
caches. Well it sounds better if we give them the chance to that...

Thanks
WANG Chao

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
