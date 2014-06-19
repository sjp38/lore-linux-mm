Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id BE5C56B0036
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 17:34:07 -0400 (EDT)
Received: by mail-ie0-f173.google.com with SMTP id y20so2545245ier.18
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 14:34:07 -0700 (PDT)
Received: from mail-ie0-x233.google.com (mail-ie0-x233.google.com [2607:f8b0:4001:c03::233])
        by mx.google.com with ESMTPS id a11si11308628icr.106.2014.06.19.14.34.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 14:34:07 -0700 (PDT)
Received: by mail-ie0-f179.google.com with SMTP id tr6so2558848ieb.10
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 14:34:07 -0700 (PDT)
Date: Thu, 19 Jun 2014 14:34:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH RESEND] slub: return correct error on slab_sysfs_init
In-Reply-To: <20140619133201.7f84ae4acbc1b9d8f65e2b4f@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1406191432220.8611@chino.kir.corp.google.com>
References: <53A0EB84.7030308@oracle.com> <alpine.DEB.2.02.1406181314290.10339@chino.kir.corp.google.com> <alpine.DEB.2.11.1406190939030.2785@gentwo.org> <20140619133201.7f84ae4acbc1b9d8f65e2b4f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@gentwo.org>, Jeff Liu <jeff.liu@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, akpm@linuxfoundation.org

On Thu, 19 Jun 2014, Andrew Morton wrote:

> > > Why?  kset_create_and_add() can fail for a few other reasons other than
> > > memory constraints and given that this is only done at bootstrap, it
> > > actually seems like a duplicate name would be a bigger concern than low on
> > > memory if another init call actually registered it.
> > 
> > Greg said that the only reason for failure would be out of memory.
> 
> The kset_create_and_add interface is busted - it should return an
> ERR_PTR on error, not NULL.  This seems to be a common gregkh failing :(
> 
> It's plausible that out-of-memory is the most common reason for
> kset_create_and_add() failure, dunno.
> 

I seriously doubt out of memory issues are the most common reason for 
failure since this is only done at init, it seems much more likely that 
someone accidently added an object of the same name, "slab", erroneous and 
then -ENOMEM wouldn't make any sense.  kset_create_and_add() can most 
certainly return other errors rather than just -ENOMEM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
