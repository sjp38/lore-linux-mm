Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 414716B0005
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 16:51:37 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id yy13so932275pab.3
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 13:51:37 -0800 (PST)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id b70si4253224pfj.56.2016.02.02.13.51.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 13:51:36 -0800 (PST)
Received: by mail-pf0-x231.google.com with SMTP id w123so1092828pfb.0
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 13:51:36 -0800 (PST)
Date: Tue, 2 Feb 2016 13:51:34 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3 2/3] x86: query dynamic DEBUG_PAGEALLOC setting
In-Reply-To: <alpine.DEB.2.10.1601281500160.31035@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1602021351290.4977@chino.kir.corp.google.com>
References: <1453889401-43496-1-git-send-email-borntraeger@de.ibm.com> <1453889401-43496-3-git-send-email-borntraeger@de.ibm.com> <alpine.DEB.2.10.1601271414180.23510@chino.kir.corp.google.com> <56A9E3D1.3090001@de.ibm.com>
 <alpine.DEB.2.10.1601281500160.31035@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net, Joonsoo Kim <iamjoonsoo.kim@lge.com>, davej@codemonkey.org.uk

On Thu, 28 Jan 2016, David Rientjes wrote:

> On Thu, 28 Jan 2016, Christian Borntraeger wrote:
> 
> > Indeed, I only touched the identity mapping and dump stack.
> > The question is do we really want to change free_init_pages as well?
> > The unmapping during runtime causes significant overhead, but the
> > unmapping after init imposes almost no runtime overhead. Of course,
> > things get fishy now as what is enabled and what not.
> > 
> > Kconfig after my patch "mm/debug_pagealloc: Ask users for default setting of debug_pagealloc"
> > (in mm) now states
> > ----snip----
> > By default this option will have a small overhead, e.g. by not
> > allowing the kernel mapping to be backed by large pages on some
> > architectures. Even bigger overhead comes when the debugging is
> > enabled by DEBUG_PAGEALLOC_ENABLE_DEFAULT or the debug_pagealloc
> > command line parameter.
> > ----snip----
> > 
> > So I am tempted to NOT change free_init_pages, but the x86 maintainers
> > can certainly decide differently. Ingo, Thomas, H. Peter, please advise.
> > 
> 
> I'm sorry, but I thought the discussion of the previous version of the 
> patchset led to deciding that all CONFIG_DEBUG_PAGEALLOC behavior would be 
> controlled by being enabled on the commandline and checked with 
> debug_pagealloc_enabled().
> 
> I don't think we should have a CONFIG_DEBUG_PAGEALLOC that does some stuff 
> and then a commandline parameter or CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT 
> to enable more stuff.  It should either be all enabled by the commandline 
> (or config option) or split into a separate entity.  
> CONFIG_DEBUG_PAGEALLOC_LIGHT and CONFIG_DEBUG_PAGEALLOC would be fine, but 
> the current state is very confusing about what is being done and what 
> isn't.
> 

Ping?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
