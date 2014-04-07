Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 544746B0035
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 15:27:40 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id v10so7043443pde.11
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 12:27:40 -0700 (PDT)
Received: from qmta10.emeryville.ca.mail.comcast.net (qmta10.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:17])
        by mx.google.com with ESMTP id m9si8804673pab.331.2014.04.07.12.27.39
        for <linux-mm@kvack.org>;
        Mon, 07 Apr 2014 12:27:39 -0700 (PDT)
Date: Mon, 7 Apr 2014 14:27:36 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3] Some printk cleanup in mm
In-Reply-To: <1396894732-17963-1-git-send-email-mitchelh@codeaurora.org>
Message-ID: <alpine.DEB.2.10.1404071427120.4447@nuc>
References: <1396894732-17963-1-git-send-email-mitchelh@codeaurora.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mitchel Humpherys <mitchelh@codeaurora.org>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 7 Apr 2014, Mitchel Humpherys wrote:

>   - v3: Leaving slub.c alone. It's using hand-tagged printk's
>     correctly so it's probably just churn to convert everything to the
>     pr_ macros.

Ok.

Ignored-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
