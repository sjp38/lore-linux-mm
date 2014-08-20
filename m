Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 221E36B0035
	for <linux-mm@kvack.org>; Tue, 19 Aug 2014 20:03:09 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so11015804pad.25
        for <linux-mm@kvack.org>; Tue, 19 Aug 2014 17:03:08 -0700 (PDT)
Received: from qmta09.emeryville.ca.mail.comcast.net (qmta09.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:96])
        by mx.google.com with ESMTP id q16si29202345pdn.96.2014.08.19.17.03.07
        for <linux-mm@kvack.org>;
        Tue, 19 Aug 2014 17:03:08 -0700 (PDT)
Date: Tue, 19 Aug 2014 19:03:03 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] [RFC] TAINT_PERFORMANCE
In-Reply-To: <53F3E1FE.1000508@codeaurora.org>
Message-ID: <alpine.DEB.2.11.1408191901370.21171@gentwo.org>
References: <20140819212604.6C94DF09@viggo.jf.intel.com> <53F3E1FE.1000508@codeaurora.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com, peterz@infradead.org, mingo@redhat.com, ak@linux.intel.com, tim.c.chen@linux.intel.com, akpm@linux-foundation.org, penberg@kernel.org, linux-mm@kvack.org

On Tue, 19 Aug 2014, Laura Abbott wrote:

> I nominate CONFIG_DEBUG_PAGEALLOC, CONFIG_SLUB_DEBUG,
> CONFIG_SLUB_DEBUG_ON as well since I've wasted days debugging
> supposed performance issues where those were on.

CONFIG_SLUB_DEBUG is not enabling debugging. It just includes the code to
do so at kernel bootup. Not a performance problem. CONFIG_SLUB_DEBUG_ON is
a performance issue since debugging will be on by default.

CONFIG_SLAB_DEBUG is also a performance issue since this option makes slab
run with debugging.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
