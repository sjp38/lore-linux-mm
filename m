Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f54.google.com (mail-bk0-f54.google.com [209.85.214.54])
	by kanga.kvack.org (Postfix) with ESMTP id 1CC8A6B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 14:21:40 -0500 (EST)
Received: by mail-bk0-f54.google.com with SMTP id u14so3092383bkz.13
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 11:21:39 -0800 (PST)
Received: from qmta11.emeryville.ca.mail.comcast.net (qmta11.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:211])
        by mx.google.com with ESMTP id og3si15245518bkb.191.2014.01.27.11.21.37
        for <linux-mm@kvack.org>;
        Mon, 27 Jan 2014 11:21:38 -0800 (PST)
Date: Mon, 27 Jan 2014 13:21:35 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] [trivial] mm: Fix warning on make htmldocs caused by
 slab.c
In-Reply-To: <1390845428-6289-1-git-send-email-standby24x7@gmail.com>
Message-ID: <alpine.DEB.2.10.1401271321190.6125@nuc>
References: <1390845428-6289-1-git-send-email-standby24x7@gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masanari Iida <standby24x7@gmail.com>
Cc: penberg@kernel.org, mpm@selenic.com, trivial@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 28 Jan 2014, Masanari Iida wrote:

> This patch fixed following errors while make htmldocs
> Warning(/mm/slab.c:1956): No description found for parameter 'page'
> Warning(/mm/slab.c:1956): Excess function parameter 'slabp' description in 'slab_destroy'

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
