Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id D19936B026A
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 11:29:37 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id e7so77531345lfe.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 08:29:37 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 186si16475529wmz.140.2016.08.01.08.29.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 08:29:36 -0700 (PDT)
Date: Mon, 1 Aug 2016 17:29:33 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [memcg:auto-latest 238/243] include/linux/compiler-gcc.h:243:38:
 error: impossible constraint in 'asm'
Message-ID: <20160801152933.GM13544@dhcp22.suse.cz>
References: <201607300506.W5FnCSrY%fengguang.wu@intel.com>
 <20160731121125.GA29775@dhcp22.suse.cz>
 <579F6422.1040202@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <579F6422.1040202@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Baron <jbaron@akamai.com>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Mon 01-08-16 11:00:50, Jason Baron wrote:
> On 07/31/2016 08:11 AM, Michal Hocko wrote:
> > It seems that this has been already reported and Jason has noticed [1] that
> > the problem is in the disabled optimizations:
> > 
> > $ grep CRYPTO_DEV_UX500_DEBUG .config
> > CONFIG_CRYPTO_DEV_UX500_DEBUG=y
> > 
> > if I disable this particular option the code compiles just fine. I have
> > no idea what is wrong about the code but it seems to depend on
> > optimizations enabled which sounds a bit scrary...
> > 
> > [1] http://www.spinics.net/lists/linux-mm/msg109590.html
> 
> 
> Hi,
> 
> There was a patch from Arnd Bergmann to address this
> issue by removing the usage of -O0 here, included in
> linux-next:
> 
> https://marc.info/?l=linux-kernel&m=146701898520633&w=2

AFAIU the code should be fixed as well. See
http://lkml.kernel.org/r/35a0878d-84bd-ad93-8810-23c861ed464e@suse.cz
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
