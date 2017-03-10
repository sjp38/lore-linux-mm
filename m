Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 284CF280901
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 09:47:31 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id w37so29917448wrc.2
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 06:47:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l24si13150596wrb.169.2017.03.10.06.47.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Mar 2017 06:47:29 -0800 (PST)
Date: Fri, 10 Mar 2017 15:47:28 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [memcg:since-4.10 474/475] ERROR: "rodata_test_data"
 [arch/x86/kernel/test_nx.ko] undefined!
Message-ID: <20170310144728.GL3753@dhcp22.suse.cz>
References: <201703102212.8VbgLe3a%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201703102212.8VbgLe3a%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>, kbuild-all@01.org, linux-mm@kvack.org

On Fri 10-03-17 22:40:14, Wu Fengguang wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-4.10
> head:   7408941b46e4595206353d4028b91e04a3e0f65b
> commit: 3f045d684db15fb0160bc0166645b16ab6b19bf6 [474/475] arch: add ARCH_HAS_SET_MEMORY config
> config: x86_64-allyesdebian (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         git checkout 3f045d684db15fb0160bc0166645b16ab6b19bf6
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All errors (new ones prefixed by >>):

This is probably my fault when I was constructing the mm git tree. The
treewide patchset was a bit of an PITA to apply correctly and I might
have forgotten to add some dependencies. Daniel you can ignore this
report and I will try to resolve this.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
