Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id 13DB082F66
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 10:18:44 -0400 (EDT)
Received: by qkcy65 with SMTP id y65so35892096qkc.0
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 07:18:43 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id p102si8212474qgp.3.2015.10.21.07.18.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 21 Oct 2015 07:18:43 -0700 (PDT)
Date: Wed, 21 Oct 2015 09:18:42 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] mm/slub: correct the comment in calculate_order()
In-Reply-To: <1445421066-10641-2-git-send-email-weiyang@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.20.1510210918280.5611@east.gentwo.org>
References: <1445421066-10641-1-git-send-email-weiyang@linux.vnet.ibm.com> <1445421066-10641-2-git-send-email-weiyang@linux.vnet.ibm.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Cc: penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org

On Wed, 21 Oct 2015, Wei Yang wrote:

> In calculate_order(), it tries to calculate the best order by adjusting the
> fraction and min_objects. On each iteration on min_objects, fraction
> iterates on 16, 8, 4. Which means the acceptable waste increases with 1/16,
> 1/8, 1/4.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
