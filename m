Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1AEBD6B0038
	for <linux-mm@kvack.org>; Wed, 17 May 2017 10:50:56 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id c15so10209296ith.7
        for <linux-mm@kvack.org>; Wed, 17 May 2017 07:50:56 -0700 (PDT)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id 200si16345575ity.27.2017.05.17.07.50.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 07:50:55 -0700 (PDT)
Date: Wed, 17 May 2017 09:50:53 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/6] mm/slub: add total_objects_partial sysfs
In-Reply-To: <20170517141146.11063-2-richard.weiyang@gmail.com>
Message-ID: <alpine.DEB.2.20.1705170950330.8714@east.gentwo.org>
References: <20170517141146.11063-1-richard.weiyang@gmail.com> <20170517141146.11063-2-richard.weiyang@gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 17 May 2017, Wei Yang wrote:

> For partial slabs, show_slab_objects could display its total objects.
>
> This patch just adds an entry to display it.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
