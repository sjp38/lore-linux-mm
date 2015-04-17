Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 28DCF6B0032
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 18:26:38 -0400 (EDT)
Received: by qgeb100 with SMTP id b100so28580082qge.3
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 15:26:37 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id p36si12904538qge.127.2015.04.17.15.26.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 17 Apr 2015 15:26:37 -0700 (PDT)
Date: Fri, 17 Apr 2015 17:26:34 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH v2 02/11] slab: add private memory allocator header
 for arch/lib
In-Reply-To: <553121E6.5000005@nod.at>
Message-ID: <alpine.DEB.2.11.1504171725100.10545@gentwo.org>
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp> <1429263374-57517-1-git-send-email-tazaki@sfc.wide.ad.jp> <1429263374-57517-3-git-send-email-tazaki@sfc.wide.ad.jp> <alpine.DEB.2.11.1504170716380.20800@gentwo.org> <55310033.1060108@nod.at>
 <m2h9se4x2b.wl@sfc.wide.ad.jp> <553121E6.5000005@nod.at>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: Hajime Tazaki <tazaki@sfc.wide.ad.jp>, linux-arch@vger.kernel.org, arnd@arndb.de, corbet@lwn.net, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, jdike@addtoit.com, rusty@rustcorp.com.au, upa@haeena.net, christoph.paasch@gmail.com, mathieu.lacage@gmail.com, libos-nuse@googlegroups.com

On Fri, 17 Apr 2015, Richard Weinberger wrote:

> SLUB is the unqueued SLAB and SLLB is the library SLAB. :D

Good that this convention is now so broadly known that I did not even
have to explain what it meant. But I think you can give it any name you
want. SLLB was just a way to tersely state how this is going to integrate
into the overall scheme of things.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
