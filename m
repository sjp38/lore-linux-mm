Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 068346B0005
	for <linux-mm@kvack.org>; Fri, 10 Jun 2016 17:32:29 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id e5so10101280ith.0
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 14:32:29 -0700 (PDT)
Received: from resqmta-po-08v.sys.comcast.net (resqmta-po-08v.sys.comcast.net. [2001:558:fe16:19:96:114:154:167])
        by mx.google.com with ESMTPS id b64si14397156ioj.204.2016.06.10.14.32.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jun 2016 14:32:28 -0700 (PDT)
Date: Fri, 10 Jun 2016 16:32:26 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH RFC] slub: reap free slabs periodically
In-Reply-To: <1465575243-18882-1-git-send-email-vdavydov@virtuozzo.com>
Message-ID: <alpine.DEB.2.20.1606101629520.6786@east.gentwo.org>
References: <1465575243-18882-1-git-send-email-vdavydov@virtuozzo.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

One reason for SLUBs creation was the 2 second scans in  SLAB which causes
significant disruption of latency sensitive tasksk.

You can simply implement a reaper in userspace by running

slabinfo -s

if you have to have this.


There is no need to duplicate SLAB problems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
