Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BEEC36B025E
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 07:22:28 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id k184so3219499wme.4
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 04:22:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eh3si89206667wjd.247.2017.01.06.04.22.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Jan 2017 04:22:27 -0800 (PST)
Date: Fri, 6 Jan 2017 13:22:25 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [zwisler:mmots_dax_tracepoint 14/143] mm/debug.c:34:21: error:
 expected expression before ',' token
Message-ID: <20170106122225.GK5556@dhcp22.suse.cz>
References: <201701062053.SDNkH5Uj%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201701062053.SDNkH5Uj%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>, kbuild test robot <fengguang.wu@intel.com>

On Fri 06-01-17 20:13:06, Wu Fengguang wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/zwisler/linux.git mmots_dax_tracepoint
> head:   da4c62b5ae469ab971d717cd9a6f7651aabe5ab9
> commit: ed24c07ce938fb44d97d5db5d653b5d51c608ec4 [14/143] mm: get rid of __GFP_OTHER_NODE
> config: i386-tinyconfig (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         git checkout ed24c07ce938fb44d97d5db5d653b5d51c608ec4
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All errors (new ones prefixed by >>):
> 
> >> mm/debug.c:34:21: error: expected expression before ',' token
>      __def_gfpflag_names,
>                         ^

I am pretty sure I have fixed this one but it got lost probably during
the rebase. Sorry about that. Here is the fixup which should be folded
into http://lkml.kernel.org/r/20170102153057.9451-3-mhocko@kernel.org

Thanks for reporting!
---
