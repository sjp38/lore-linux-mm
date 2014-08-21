Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9E8C46B0035
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 10:15:58 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id et14so14573243pad.23
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 07:15:58 -0700 (PDT)
Received: from qmta12.emeryville.ca.mail.comcast.net (qmta12.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:227])
        by mx.google.com with ESMTP id gy1si36585751pbd.29.2014.08.21.07.15.57
        for <linux-mm@kvack.org>;
        Thu, 21 Aug 2014 07:15:57 -0700 (PDT)
Date: Thu, 21 Aug 2014 09:15:54 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/5] mm/sl[ao]b: always track caller in
 kmalloc_(node_)track_caller()
In-Reply-To: <1408608562-20339-2-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.11.1408210915310.32524@gentwo.org>
References: <1408608562-20339-1-git-send-email-iamjoonsoo.kim@lge.com> <1408608562-20339-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 21 Aug 2014, Joonsoo Kim wrote:

> >From this change, we can turn on/off CONFIG_DEBUG_SLAB without full
> kernel build and remove some complicated '#if' defintion. It looks
> more benefitial to me.

I agree.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
