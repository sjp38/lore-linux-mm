Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1EAAE6B00EE
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 06:27:10 -0400 (EDT)
Date: Mon, 15 Aug 2011 12:27:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: Switch NUMA_BUILD and COMPACTION_BUILD to new
 IS_ENABLED() syntax
Message-ID: <20110815102707.GA3967@tiehlicka.suse.cz>
References: <1312989160-737-1-git-send-email-mmarek@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1312989160-737-1-git-send-email-mmarek@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Marek <mmarek@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 10-08-11 17:12:40, Michal Marek wrote:
> Introduced in 3.1-rc1, IS_ENABLED(CONFIG_NUMA) expands to a true value
> iff CONFIG_NUMA is set. This makes it easier to grep for code that
> depends on CONFIG_NUMA.

It looks this doesn't work properly. I can see the following build
error:
  CHK     include/linux/version.h
  CHK     include/generated/utsrelease.h
  UPD     include/generated/utsrelease.h
  CC      arch/x86/kernel/asm-offsets.s
In file included from include/linux/kmod.h:22:0,
                 from include/linux/module.h:13,
                 from include/linux/crypto.h:21,
                 from arch/x86/kernel/asm-offsets.c:8:
include/linux/gfp.h: In function a??gfp_zonelista??:
include/linux/gfp.h:265:1: error: a??__enabled_CONFIG_NUMAa?? undeclared (first use in this function)
include/linux/gfp.h:265:1: note: each undeclared identifier is reported only once for each function it appears in
include/linux/gfp.h:265:1: error: a??__enabled_CONFIG_NUMA_MODULEa?? undeclared (first use in this function)
make[1]: *** [arch/x86/kernel/asm-offsets.s] Error 1

I do not have CONFIG_NUMA set so it seems to have issues with config
symbols which are not set to any value. Is this something that could be
fixed?
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
