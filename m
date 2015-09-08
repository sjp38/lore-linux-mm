Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2E7626B0255
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 13:49:45 -0400 (EDT)
Received: by iofb144 with SMTP id b144so127834695iof.1
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 10:49:45 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id 40si3901485ios.168.2015.09.08.10.49.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 08 Sep 2015 10:49:44 -0700 (PDT)
Date: Tue, 8 Sep 2015 12:49:43 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slab:Fix the unexpected index mapping result of kmalloc_size(INDEX_NODE
 + 1)
In-Reply-To: <20150907053855.GC21207@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.11.1509081249240.26204@east.gentwo.org>
References: <OF591717D2.930C6B40-ON48257E7D.0017016C-48257E7D.0020AFB4@zte.com.cn> <20150729152803.67f593847050419a8696fe28@linux-foundation.org> <20150731001827.GA15029@js1304-P5Q-DELUXE> <alpine.DEB.2.11.1507310845440.11895@east.gentwo.org>
 <20150807015609.GB15802@js1304-P5Q-DELUXE> <20150904132902.5d62a09077435d742d6f2f1b@linux-foundation.org> <20150907053855.GC21207@js1304-P5Q-DELUXE>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, liu.hailong6@zte.com.cn, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, jiang.xuexin@zte.com.cn, David Rientjes <rientjes@google.com>

On Mon, 7 Sep 2015, Joonsoo Kim wrote:

> Sure. It should be fixed soon. If Christoph agree with my approach, I
> will make it to proper formatted patch.

Could you explain that approach again?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
