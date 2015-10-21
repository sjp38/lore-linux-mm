Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4AA4782F66
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 10:19:11 -0400 (EDT)
Received: by oies66 with SMTP id s66so29508334oie.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 07:19:11 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id g4si5492892oif.40.2015.10.21.07.19.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 21 Oct 2015 07:19:10 -0700 (PDT)
Date: Wed, 21 Oct 2015 09:19:09 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] mm/slub: use get_order() instead of fls()
In-Reply-To: <1445421066-10641-3-git-send-email-weiyang@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.20.1510210918520.5611@east.gentwo.org>
References: <1445421066-10641-1-git-send-email-weiyang@linux.vnet.ibm.com> <1445421066-10641-3-git-send-email-weiyang@linux.vnet.ibm.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Cc: penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org

On Wed, 21 Oct 2015, Wei Yang wrote:

> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
> Pekka Enberg <penberg@kernel.org>

Acked-by: ?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
