Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 31E226B0005
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 10:57:44 -0500 (EST)
Received: by mail-vk0-f70.google.com with SMTP id d1so57577vke.16
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 07:57:44 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id 125si220971vkg.32.2018.02.15.07.57.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Feb 2018 07:57:43 -0800 (PST)
Date: Thu, 15 Feb 2018 09:55:11 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] mm: Add kvmalloc_ab_c and kvzalloc_struct
In-Reply-To: <20180214201400.GD20627@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1802150953080.1902@nuc-kabylake>
References: <20180214182618.14627-1-willy@infradead.org> <20180214182618.14627-3-willy@infradead.org> <alpine.DEB.2.20.1802141354530.28235@nuc-kabylake> <20180214201400.GD20627@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Wed, 14 Feb 2018, Matthew Wilcox wrote:

> > Uppercase like the similar KMEM_CACHE related macros in
> > include/linux/slab.h?>
>
> Do you think that would look better in the users?  Compare:

Does looking matter? I thought we had the convention that macros are
uppercase. There are some tricks going on with the struct. Uppercase shows
that something special is going on.

> Making it look like a function is more pleasing to my eye, but I'll
> change it if that's the only thing keeping it from being merged.

This should be consistent throughout the source.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
