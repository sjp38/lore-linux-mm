Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1AC06900015
	for <linux-mm@kvack.org>; Fri, 13 Feb 2015 18:58:42 -0500 (EST)
Received: by mail-qg0-f41.google.com with SMTP id i50so15864675qgf.0
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 15:58:41 -0800 (PST)
Received: from resqmta-ch2-07v.sys.comcast.net ([2001:558:fe21:29:250:56ff:feaf:3843])
        by mx.google.com with ESMTPS id a19si4675353qgf.82.2015.02.13.15.58.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 13 Feb 2015 15:58:40 -0800 (PST)
Date: Fri, 13 Feb 2015 17:58:38 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] mm: slub: Add SLAB_DEBUG_CRASH option
In-Reply-To: <alpine.DEB.2.10.1502131537430.25326@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.11.1502131758130.14618@gentwo.org>
References: <1423865980-10417-1-git-send-email-chris.j.arges@canonical.com> <1423865980-10417-3-git-send-email-chris.j.arges@canonical.com> <alpine.DEB.2.10.1502131537430.25326@chino.kir.corp.google.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Chris J Arges <chris.j.arges@canonical.com>, linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org

On Fri, 13 Feb 2015, David Rientjes wrote:

> Why isn't this done in other debugging functions such as
> free_debug_processing()?

I think this belongs into the functions that report the bug. They should
report the issue and at the end of the report crash.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
