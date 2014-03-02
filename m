Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5C0DF6B0038
	for <linux-mm@kvack.org>; Sat,  1 Mar 2014 19:59:11 -0500 (EST)
Received: by mail-qa0-f51.google.com with SMTP id j7so2217693qaq.10
        for <linux-mm@kvack.org>; Sat, 01 Mar 2014 16:59:11 -0800 (PST)
Received: from qmta01.emeryville.ca.mail.comcast.net (qmta01.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:16])
        by mx.google.com with ESMTP id f6si3580175qap.40.2014.03.01.16.59.10
        for <linux-mm@kvack.org>;
        Sat, 01 Mar 2014 16:59:10 -0800 (PST)
Date: Sat, 1 Mar 2014 18:59:07 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slab.c: cleanup outdated comments and unify variables
 naming
In-Reply-To: <20140227073258.GA11087@meta-silence.Home>
Message-ID: <alpine.DEB.2.10.1403011858040.14057@nuc>
References: <20140227073258.GA11087@meta-silence.Home>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: linux-mm@kvack.org, penberg@kernel.org, mpm@selenic.com, linux-kernel@vger.kernel.org

On Thu, 27 Feb 2014, Jianyu Zhan wrote:

> As time goes, the code changes a lot, and this leads to that
> some old-days comments scatter around , which instead of faciliating
> understanding, but make more confusion. So this patch cleans up them.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
