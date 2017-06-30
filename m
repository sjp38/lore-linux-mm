Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id F03BD2802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 08:15:10 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p204so6936491wmg.3
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 05:15:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b97si6022045wrd.50.2017.06.30.05.15.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Jun 2017 05:15:09 -0700 (PDT)
Date: Fri, 30 Jun 2017 14:15:06 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [memcg:since-4.11 538/546]
 arch/x86/include/asm/stackprotector.h:77:12: error: 'CANARY_MASK' undeclared
Message-ID: <20170630121505.GI22917@dhcp22.suse.cz>
References: <201706301929.ZTFA1yFG%fengguang.wu@intel.com>
 <20170630115718.GH22917@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170630115718.GH22917@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Rik van Riel <riel@redhat.com>, kbuild-all@01.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Fri 30-06-17 13:57:18, Michal Hocko wrote:
> On Fri 30-06-17 19:45:31, Wu Fengguang wrote:
> > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-4.11
> > head:   7398359c52bfc0e6188552bc391c717910db1a22
> > commit: a76bbabc83c87148e249810efba03a1b7a5952d3 [538/546] x86: ascii armor the x86_64 boot init stack canary
> > config: x86_64-randconfig-x010-201726 (attached as .config)
> > compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> > reproduce:
> >         git checkout a76bbabc83c87148e249810efba03a1b7a5952d3
> >         # save the attached .config to linux build tree
> >         make ARCH=x86_64 
> > 
> > All errors (new ones prefixed by >>):
> > 
> >    In file included from include/linux/stackprotector.h:9:0,
> >                     from arch/x86/kernel/process.c:22:
> >    arch/x86/include/asm/stackprotector.h: In function 'boot_init_stack_canary':
> > >> arch/x86/include/asm/stackprotector.h:77:12: error: 'CANARY_MASK' undeclared (first use in this function)
> >      canary &= CANARY_MASK;
> >                ^~~~~~~~~~~
> 
> My fault. I've screwed applying
> randomstackprotect-introduce-get_random_canary-function.patch. Will fix
> that up and update my mmotm git tree. Sorry about that!

My build test batter hasn't caught it because all my configs use
CONFIG_CC_STACKPROTECTOR_NONE=y and allyesconfig seems to use the same.
I have added a config which enforces CONFIG_CC_STACKPROTECTOR=y to the
tested configs.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
