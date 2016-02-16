Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id EED326B0009
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 11:30:24 -0500 (EST)
Received: by mail-io0-f177.google.com with SMTP id z135so128448482iof.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 08:30:24 -0800 (PST)
Received: from resqmta-po-05v.sys.comcast.net (resqmta-po-05v.sys.comcast.net. [2001:558:fe16:19:96:114:154:164])
        by mx.google.com with ESMTPS id mr2si16176772obb.80.2016.02.16.08.30.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 16 Feb 2016 08:30:24 -0800 (PST)
Date: Tue, 16 Feb 2016 10:30:11 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCHv2 2/4] slub: Fix/clean free_debug_processing return
 paths
In-Reply-To: <1455561864-4217-3-git-send-email-labbott@fedoraproject.org>
Message-ID: <alpine.DEB.2.20.1602161029440.4158@east.gentwo.org>
References: <1455561864-4217-1-git-send-email-labbott@fedoraproject.org> <1455561864-4217-3-git-send-email-labbott@fedoraproject.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@fedoraproject.org>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>

On Mon, 15 Feb 2016, Laura Abbott wrote:

> Since 19c7ff9ecd89 ("slub: Take node lock during object free checks")
> check_object has been incorrectly returning success as it follows
> the out label which just returns the node. Thanks to refactoring,
> the out and fail paths are now basically the same. Combine the two
> into one and just use a single label.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
