Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 8B92A6B0031
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 14:44:15 -0400 (EDT)
Received: by mail-ig0-f181.google.com with SMTP id h18so3855527igc.8
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 11:44:15 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0147.hostedemail.com. [216.40.44.147])
        by mx.google.com with ESMTP id u6si18946943icp.74.2014.03.31.11.44.06
        for <linux-mm@kvack.org>;
        Mon, 31 Mar 2014 11:44:06 -0700 (PDT)
Message-ID: <1396291441.21529.52.camel@joe-AO722>
Subject: Re: [PATCH v2] mm: convert some level-less printks to pr_*
From: Joe Perches <joe@perches.com>
Date: Mon, 31 Mar 2014 11:44:01 -0700
In-Reply-To: <alpine.DEB.2.10.1403311334060.3313@nuc>
References: <1395942859-11611-1-git-send-email-mitchelh@codeaurora.org>
	 <1395942859-11611-2-git-send-email-mitchelh@codeaurora.org>
	 <alpine.DEB.2.10.1403311334060.3313@nuc>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Mitchel Humpherys <mitchelh@codeaurora.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 2014-03-31 at 13:35 -0500, Christoph Lameter wrote:
> On Thu, 27 Mar 2014, Mitchel Humpherys wrote:
> 
> > diff --git a/mm/slub.c b/mm/slub.c
[]
> > @@ -9,6 +9,8 @@
> >   * (C) 2011 Linux Foundation, Christoph Lameter
> >   */
> >
> > +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> 
> This is implicitly used by some macros? If so then please define this
> elsewhere. I do not see any use in slub.c of this one.

Hi Christoph

All the pr_<level> macros use it.

from include/linux/printk.h:

#ifndef pr_fmt
#define pr_fmt(fmt) fmt
#endif

#define pr_emerg(fmt, ...) \
	printk(KERN_EMERG pr_fmt(fmt), ##__VA_ARGS__)

etc...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
