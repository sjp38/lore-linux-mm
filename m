Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4FCBB6B0035
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 10:22:39 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa1so14601681pad.13
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 07:22:38 -0700 (PDT)
Received: from qmta12.emeryville.ca.mail.comcast.net (qmta12.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:227])
        by mx.google.com with ESMTP id gy1si36585751pbd.29.2014.08.21.07.22.38
        for <linux-mm@kvack.org>;
        Thu, 21 Aug 2014 07:22:38 -0700 (PDT)
Date: Thu, 21 Aug 2014 09:22:35 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] mm/slab_common: commonize slab merge logic
In-Reply-To: <1408608675-20420-2-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.11.1408210922020.32524@gentwo.org>
References: <1408608675-20420-1-git-send-email-iamjoonsoo.kim@lge.com> <1408608675-20420-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 21 Aug 2014, Joonsoo Kim wrote:

> Slab merge is good feature to reduce fragmentation. Now, it is only
> applied to SLUB, but, it would be good to apply it to SLAB. This patch
> is preparation step to apply slab merge to SLAB by commonizing slab
> merge logic.

Oh. Wow. Never thought that would be possible. Need to have some more time
to review this though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
