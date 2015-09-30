Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 22D766B0263
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 09:53:05 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so47989608ioi.2
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 06:53:05 -0700 (PDT)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id gb2si676754igd.93.2015.09.30.06.53.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 30 Sep 2015 06:53:04 -0700 (PDT)
Date: Wed, 30 Sep 2015 08:53:03 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slub: calculate start order with reserved in
 consideration
In-Reply-To: <1443580202-4311-1-git-send-email-weiyang@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.20.1509300852500.16540@east.gentwo.org>
References: <1443580202-4311-1-git-send-email-weiyang@linux.vnet.ibm.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Cc: penberg@kernel.org, rientjes@google.com, linux-mm@kvack.org

On Wed, 30 Sep 2015, Wei Yang wrote:

> In function slub_order(), the order starts from max(min_order,
> get_order(min_objects * size)). When (min_objects * size) has different
> order with (min_objects * size + reserved), it will skip this order by the
> check in the loop.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
