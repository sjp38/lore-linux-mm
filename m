Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id D171B900015
	for <linux-mm@kvack.org>; Fri, 13 Feb 2015 19:16:54 -0500 (EST)
Received: by mail-qa0-f44.google.com with SMTP id n8so14856404qaq.3
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 16:16:54 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net ([2001:558:fe21:29:250:56ff:feaf:60fe])
        by mx.google.com with ESMTPS id c13si4752979qaw.34.2015.02.13.16.16.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 13 Feb 2015 16:16:54 -0800 (PST)
Date: Fri, 13 Feb 2015 18:16:52 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] mm: slub: Add SLAB_DEBUG_CRASH option
In-Reply-To: <54DE8E47.5040800@canonical.com>
Message-ID: <alpine.DEB.2.11.1502131810520.14741@gentwo.org>
References: <1423865980-10417-1-git-send-email-chris.j.arges@canonical.com> <1423865980-10417-3-git-send-email-chris.j.arges@canonical.com> <alpine.DEB.2.10.1502131537430.25326@chino.kir.corp.google.com> <54DE8E47.5040800@canonical.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris J Arges <chris.j.arges@canonical.com>
Cc: David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org

On Fri, 13 Feb 2015, Chris J Arges wrote:

> The diff doesn't show this clearly, but the BUG_ON was added to both
> free_debug_processing and alloc_debug_processing.

This is not good. There should be no BUG_ON. The problem report by the
allocator already includes a backtrace. You need to abort with the crash
dump. Maybe print a message describing what is going on before.

Crash dump and abort would make most sense in slab_err() and object_err().


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
