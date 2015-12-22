Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 961EA82F64
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 13:08:19 -0500 (EST)
Received: by mail-io0-f177.google.com with SMTP id 186so196867224iow.0
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 10:08:19 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id ik1si35092195igb.24.2015.12.22.10.08.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 22 Dec 2015 10:08:18 -0800 (PST)
Date: Tue, 22 Dec 2015 12:08:17 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [kernel-hardening] [RFC][PATCH 6/7] mm: Add Kconfig option for
 slab sanitization
In-Reply-To: <56798851.60906@intel.com>
Message-ID: <alpine.DEB.2.20.1512221207230.14406@east.gentwo.org>
References: <1450755641-7856-1-git-send-email-laura@labbott.name> <1450755641-7856-7-git-send-email-laura@labbott.name> <567964F3.2020402@intel.com> <alpine.DEB.2.20.1512221023550.2748@east.gentwo.org> <567986E7.50107@intel.com> <alpine.DEB.2.20.1512221124230.14335@east.gentwo.org>
 <56798851.60906@intel.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: kernel-hardening@lists.openwall.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <laura@labbott.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>

On Tue, 22 Dec 2015, Dave Hansen wrote:

> > Why would you use zeros? The point is just to clear the information right?
> > The regular poisoning does that.
>
> It then allows you to avoid the zeroing at allocation time.

Well much of the code is expecting a zeroed object from the allocator and
its zeroed at that time. Zeroing makes the object cache hot which is an
important performance aspect.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
