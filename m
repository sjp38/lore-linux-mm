Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id C1EA96B0031
	for <linux-mm@kvack.org>; Wed, 26 Mar 2014 20:38:58 -0400 (EDT)
Received: by mail-ie0-f181.google.com with SMTP id tp5so2556919ieb.12
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 17:38:58 -0700 (PDT)
Received: from qmta15.emeryville.ca.mail.comcast.net (qmta15.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:228])
        by mx.google.com with ESMTP id nx5si304152icb.26.2014.03.26.17.38.57
        for <linux-mm@kvack.org>;
        Wed, 26 Mar 2014 17:38:57 -0700 (PDT)
Date: Wed, 26 Mar 2014 19:38:54 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: convert some level-less printks to pr_*
In-Reply-To: <1395877783-18910-2-git-send-email-mitchelh@codeaurora.org>
Message-ID: <alpine.DEB.2.10.1403261938160.5585@nuc>
References: <1395877783-18910-1-git-send-email-mitchelh@codeaurora.org> <1395877783-18910-2-git-send-email-mitchelh@codeaurora.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mitchel Humpherys <mitchelh@codeaurora.org>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 26 Mar 2014, Mitchel Humpherys wrote:

> printk is meant to be used with an associated log level. There are some
> instances of printk scattered around the mm code where the log level is
> missing. Add a log level and adhere to suggestions by
> scripts/checkpatch.pl by moving to the pr_* macros.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
