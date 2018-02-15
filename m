Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8FCAE6B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 12:06:56 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id p189so846496iod.2
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 09:06:56 -0800 (PST)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id g80si3241248ioe.172.2018.02.15.09.06.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Feb 2018 09:06:55 -0800 (PST)
Date: Thu, 15 Feb 2018 11:06:54 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] mm: Add kvmalloc_ab_c and kvzalloc_struct
In-Reply-To: <20180215162303.GC12360@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1802151104140.2970@nuc-kabylake>
References: <20180214182618.14627-1-willy@infradead.org> <20180214182618.14627-3-willy@infradead.org> <alpine.DEB.2.20.1802141354530.28235@nuc-kabylake> <20180214201400.GD20627@bombadil.infradead.org> <alpine.DEB.2.20.1802150953080.1902@nuc-kabylake>
 <20180215162303.GC12360@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Thu, 15 Feb 2018, Matthew Wilcox wrote:

> I dunno.  Yes, there's macro trickery going on here, but it certainly
> resembles a function.  It doesn't fail any of the rules laid out in that
> chapter of coding-style about unacceptable uses of macros.

It sure looks like a function but does magic things with the struct
parameter. So its not working like a function and the capitalization makes
one aware of that.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
