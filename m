Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 230D66B0038
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 14:27:10 -0400 (EDT)
Received: by iggg4 with SMTP id g4so8406711igg.0
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 11:27:09 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id 79si4314836iog.101.2015.04.06.11.27.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 06 Apr 2015 11:27:09 -0700 (PDT)
Date: Mon, 6 Apr 2015 13:27:07 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Slab infrastructure for bulk object allocation and freeing V2
In-Reply-To: <20150402134239.8e8c538103640d697246ba6a@linux-foundation.org>
Message-ID: <alpine.DEB.2.11.1504061325350.27939@gentwo.org>
References: <alpine.DEB.2.11.1503300927290.6646@gentwo.org> <20150331142025.63249f2f0189aee231a6e0c8@linux-foundation.org> <alpine.DEB.2.11.1504020922120.28416@gentwo.org> <20150402134239.8e8c538103640d697246ba6a@linux-foundation.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linuxfoundation.org, Pekka Enberg <penberg@kernel.org>, iamjoonsoo@lge.com

On Thu, 2 Apr 2015, Andrew Morton wrote:

> hm, OK.  The per-allocator wrappers could be made static inline in .h
> if that makes sense.

The allocators will add code to the "per-allocator wrappers". Inlining
that would be bad. Basicalkly the "wrapper" is the skeleon to which
optimizations can be added while keeping the call to the generic
implementaiton if the allocator has to punt for some reason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
