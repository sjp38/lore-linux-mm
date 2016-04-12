Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 06C996B0005
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 12:41:15 -0400 (EDT)
Received: by mail-io0-f176.google.com with SMTP id u185so35568226iod.3
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 09:41:15 -0700 (PDT)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id qh3si22038426igb.35.2016.04.12.09.41.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 09:41:14 -0700 (PDT)
Date: Tue, 12 Apr 2016 11:41:09 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 02/11] mm/slab: remove BAD_ALIEN_MAGIC again
In-Reply-To: <1460436666-20462-3-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.20.1604121140570.14315@east.gentwo.org>
References: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com> <1460436666-20462-3-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>


Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
