Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id D3FC06B0070
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 06:01:23 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id rl12so668408iec.37
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 03:01:23 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id yr8si15039796igb.45.2014.06.05.03.01.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jun 2014 03:01:23 -0700 (PDT)
Received: from compute3.internal (compute3.nyi.mail.srv.osa [10.202.2.43])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 7C0C321460
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 06:01:19 -0400 (EDT)
Message-ID: <53903FED.6020308@iki.fi>
Date: Thu, 05 Jun 2014 13:01:17 +0300
From: Pekka Enberg <penberg@iki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] SLAB Maintainer update
References: <alpine.DEB.2.10.1406041417290.14004@gentwo.org>
In-Reply-To: <alpine.DEB.2.10.1406041417290.14004@gentwo.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, mpm@selenic.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

On 06/04/2014 10:20 PM, Christoph Lameter wrote:
> As discussed in various threads on the side:
>
>
> Remove one inactive maintainer, add two new ones and update
> my email address. Plus add Andrew. And fix the glob to include
> files like mm/slab_common.c
>
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
