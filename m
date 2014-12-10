Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 871A36B006E
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 10:17:35 -0500 (EST)
Received: by mail-ie0-f181.google.com with SMTP id tp5so2826508ieb.12
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 07:17:35 -0800 (PST)
Received: from resqmta-po-04v.sys.comcast.net (resqmta-po-04v.sys.comcast.net. [2001:558:fe16:19:96:114:154:163])
        by mx.google.com with ESMTPS id e8si2441854ick.3.2014.12.10.07.17.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 10 Dec 2014 07:17:34 -0800 (PST)
Date: Wed, 10 Dec 2014 09:17:32 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 0/3] Faster than SLAB caching of SKBs with qmempool
 (backed by alf_queue)
In-Reply-To: <20141210141332.31779.56391.stgit@dragon>
Message-ID: <alpine.DEB.2.11.1412100917020.4047@gentwo.org>
References: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20> <20141210141332.31779.56391.stgit@dragon>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Wed, 10 Dec 2014, Jesper Dangaard Brouer wrote:

>  Patch1: alf_queue (Lock-Free queue)

For some reason that key patch is not in my linux-mm archives nor in my
inbox.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
