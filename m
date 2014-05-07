Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id EA2A76B0038
	for <linux-mm@kvack.org>; Wed,  7 May 2014 10:25:08 -0400 (EDT)
Received: by mail-qg0-f42.google.com with SMTP id q107so1142940qgd.29
        for <linux-mm@kvack.org>; Wed, 07 May 2014 07:25:08 -0700 (PDT)
Received: from qmta15.emeryville.ca.mail.comcast.net (qmta15.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:228])
        by mx.google.com with ESMTP id s10si6790966qak.37.2014.05.07.07.25.08
        for <linux-mm@kvack.org>;
        Wed, 07 May 2014 07:25:08 -0700 (PDT)
Date: Wed, 7 May 2014 09:25:05 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 09/10] slab: remove a useless lockdep annotation
In-Reply-To: <1399442780-28748-10-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.10.1405070924450.12543@gentwo.org>
References: <1399442780-28748-1-git-send-email-iamjoonsoo.kim@lge.com> <1399442780-28748-10-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Wed, 7 May 2014, Joonsoo Kim wrote:

> Now, there is no code to hold two lock simultaneously, since
> we don't call slab_destroy() with holding any lock. So, lockdep
> annotation is useless now. Remove it.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
