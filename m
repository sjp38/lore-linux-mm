Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 128B86B0031
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 12:10:58 -0400 (EDT)
Received: by mail-ig0-f175.google.com with SMTP id ur14so1761117igb.8
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 09:10:57 -0700 (PDT)
Received: from qmta04.emeryville.ca.mail.comcast.net (qmta04.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:40])
        by mx.google.com with ESMTP id j5si6903034igj.39.2014.03.27.09.10.56
        for <linux-mm@kvack.org>;
        Thu, 27 Mar 2014 09:10:56 -0700 (PDT)
Date: Thu, 27 Mar 2014 11:10:53 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: convert some level-less printks to pr_*
In-Reply-To: <alpine.DEB.2.10.1403261938160.5585@nuc>
Message-ID: <alpine.DEB.2.10.1403271110010.10482@nuc>
References: <1395877783-18910-1-git-send-email-mitchelh@codeaurora.org> <1395877783-18910-2-git-send-email-mitchelh@codeaurora.org> <alpine.DEB.2.10.1403261938160.5585@nuc>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mitchel Humpherys <mitchelh@codeaurora.org>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Would like to retracting the ack after seeing the other comments. Will ack
after then issues have been fixed.

On Wed, 26 Mar 2014, Christoph Lameter wrote:

> On Wed, 26 Mar 2014, Mitchel Humpherys wrote:
>
> > printk is meant to be used with an associated log level. There are some
> > instances of printk scattered around the mm code where the log level is
> > missing. Add a log level and adhere to suggestions by
> > scripts/checkpatch.pl by moving to the pr_* macros.
>
> Acked-by: Christoph Lameter <cl@linux.com>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
