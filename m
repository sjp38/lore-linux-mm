Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 44EBC6B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 22:04:19 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so24353267pac.2
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 19:04:19 -0700 (PDT)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com. [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id g14si11253050pdf.232.2015.06.09.19.04.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 19:04:18 -0700 (PDT)
Received: by pdbki1 with SMTP id ki1so26497741pdb.1
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 19:04:18 -0700 (PDT)
Date: Wed, 10 Jun 2015 11:04:44 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH 0/5] do not dereference NULL pools in pools'
 destroy() functions
Message-ID: <20150610020444.GA566@swordfish>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20150609142523.b717dba6033ee08de997c8be@linux-foundation.org>
 <alpine.DEB.2.11.1506092008220.3300@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1506092008220.3300@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com, Joe Perches <joe@perches.com>

On (06/09/15 20:11), Christoph Lameter wrote:
> On Tue, 9 Jun 2015, Andrew Morton wrote:
> 
> > Well I like it, even though it's going to cause a zillion little cleanup
> > patches.
> >
> > checkpatch already has a "kfree(NULL) is safe and this check is
> > probably not required" test so I guess Joe will need to get busy ;)
> >
> > I'll park these patches until after 4.1 is released - it's getting to
> > that time...
> 
> Why do this at all?

this makes things less fragile.

> I understand that kfree/kmem_cache_free can take a
> null pointer but this is the destruction of a cache and it usually
> requires multiple actions to clean things up and these actions have to be
> properly sequenced. All other processors have to stop referencing this
> cache before it can be destroyed. 

>I think failing

well, it's not just `failing', it's a NULL pointer deref.

> if someone does something strange like doing cache destruction with a
> NULL pointer is valuable.
> 

a missing check is not `something strange'. it's just happening.

(a very quick google search)
http://help.lockergnome.com/linux/PATCH-dlm-NULL-dereference-failure-kmem_cache_create--ftopict555436.html
http://linux-kernel.2935.n7.nabble.com/PATCH-2-6-30-rc6-Remove-kmem-cache-destroy-in-s3c24xx-dma-init-td460417.html
etc.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
