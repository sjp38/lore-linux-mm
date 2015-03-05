Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id A0D6D6B006C
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 18:44:25 -0500 (EST)
Received: by oigi138 with SMTP id i138so14824765oig.6
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 15:44:25 -0800 (PST)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id bp4si4892712obb.28.2015.03.05.15.44.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 15:44:24 -0800 (PST)
Message-ID: <1425599023.17007.293.camel@misato.fc.hp.com>
Subject: Re: [PATCH] Fix undefined ioremap_huge_init when CONFIG_MMU is not
 set
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 05 Mar 2015 16:43:43 -0700
In-Reply-To: <20150306104113.555c8888@canb.auug.org.au>
References: <1425570246-812-1-git-send-email-toshi.kani@hp.com>
	 <20150306104113.555c8888@canb.auug.org.au>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, kbuild-all@01.org, fengguang.wu@intel.com, hannes@cmpxchg.org

On Fri, 2015-03-06 at 10:41 +1100, Stephen Rothwell wrote:
> Hi Toshi,
> 
> On Thu,  5 Mar 2015 08:44:06 -0700 Toshi Kani <toshi.kani@hp.com> wrote:
> >
> > Fix a build error, undefined reference to ioremap_huge_init, when
> > CONFIG_MMU is not defined on linux-next and -mm tree.
> > 
> > lib/ioremap.o is not linked to the kernel when CONFIG_MMU is not
> > defined.
> > 
> > Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> > ---
> >  include/linux/io.h |    5 +++--
> >  lib/ioremap.c      |    1 -
> >  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> Added to my copy of the akpm-current tree today (and so into linux-next).

Thanks Stephen!
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
