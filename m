Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id DF4B26B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 11:28:47 -0500 (EST)
Received: by mail-io0-f177.google.com with SMTP id 9so199646959iom.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 08:28:47 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id i12si36129393igt.72.2016.02.16.08.28.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 16 Feb 2016 08:28:47 -0800 (PST)
Date: Tue, 16 Feb 2016 10:28:46 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCHv2 1/4] slub: Drop lock at the end of
 free_debug_processing
In-Reply-To: <1455561864-4217-2-git-send-email-labbott@fedoraproject.org>
Message-ID: <alpine.DEB.2.20.1602161028220.4158@east.gentwo.org>
References: <1455561864-4217-1-git-send-email-labbott@fedoraproject.org> <1455561864-4217-2-git-send-email-labbott@fedoraproject.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@fedoraproject.org>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>

On Mon, 15 Feb 2016, Laura Abbott wrote:

> Credit to Mathias Krause for the original work which inspired this series

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
