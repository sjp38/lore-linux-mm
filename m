Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id DCD036B0035
	for <linux-mm@kvack.org>; Wed, 12 Mar 2014 20:49:46 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id jt11so298734pbb.28
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 17:49:46 -0700 (PDT)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id ey10si121717pab.24.2014.03.12.17.49.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 12 Mar 2014 17:49:46 -0700 (PDT)
Received: by mail-pd0-f170.google.com with SMTP id v10so299995pde.1
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 17:49:45 -0700 (PDT)
Date: Wed, 12 Mar 2014 17:49:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RESEND PATCH] slub: fix high order page allocation problem with
  __GFP_NOFAIL
In-Reply-To: <1394612780-8033-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.02.1403121748590.17116@chino.kir.corp.google.com>
References: <1394612780-8033-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Christian Casteyde <casteyde.christian@free.fr>

On Wed, 12 Mar 2014, Joonsoo Kim wrote:

> SLUB already try to allocate high order page with clearing __GFP_NOFAIL.
> But, when allocating shadow page for kmemcheck, it missed clearing
> the flag. This trigger WARN_ON_ONCE() reported by Christian Casteyde.
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=65991
> https://lkml.org/lkml/2013/12/3/764
> 
> This patch fix this situation by using same allocation flag as original
> allocation.
> 
> Reported-by: Christian Casteyde <casteyde.christian@free.fr>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
