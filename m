Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6F7F16B0009
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 08:35:53 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id d17so8879985wrc.19
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 05:35:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l25si6613565wrl.367.2018.02.12.05.35.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Feb 2018 05:35:51 -0800 (PST)
Date: Mon, 12 Feb 2018 14:35:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [nf:master 1/9] arch/x86/tools/insn_decoder_test: warning:
 ffffffff817c07c3:	0f ff e9             	ud0    %ecx,%ebp
Message-ID: <20180212133547.GD3443@dhcp22.suse.cz>
References: <201802071027.gHIvqB29%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201802071027.gHIvqB29%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, Pablo Neira Ayuso <pablo@netfilter.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed 07-02-18 10:16:31, Wu Fengguang wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master
> head:   b408c5b04f82fe4e20bceb8e4f219453d4f21f02
> commit: 0537250fdc6c876ed4cbbe874c739aebef493ee2 [1/9] netfilter: x_tables: make allocation less aggressive
> config: x86_64-rhel-7.2 (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
> reproduce:
>         git checkout 0537250fdc6c876ed4cbbe874c739aebef493ee2
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All warnings (new ones prefixed by >>):
> 
>    arch/x86/tools/insn_decoder_test: warning: Found an x86 instruction decoder bug, please report this.
>    arch/x86/tools/insn_decoder_test: warning: ffffffff817aed81:	0f ff c3             	ud0    %ebx,%eax

I really fail to see how the above patch could have made any difference.
I am even not sure what the actual bug is, to be honest.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
