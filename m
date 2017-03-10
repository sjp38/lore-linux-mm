Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B7A6F280928
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 10:10:21 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id v125so170568028qkh.5
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 07:10:21 -0800 (PST)
Received: from www62.your-server.de (www62.your-server.de. [213.133.104.62])
        by mx.google.com with ESMTPS id f5si8248326qkb.239.2017.03.10.07.10.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Mar 2017 07:10:20 -0800 (PST)
Message-ID: <58C2C1D3.9000501@iogearbox.net>
Date: Fri, 10 Mar 2017 16:10:11 +0100
From: Daniel Borkmann <daniel@iogearbox.net>
MIME-Version: 1.0
Subject: Re: [memcg:since-4.10 474/475] ERROR: "rodata_test_data" [arch/x86/kernel/test_nx.ko]
 undefined!
References: <201703102212.8VbgLe3a%fengguang.wu@intel.com> <20170310144728.GL3753@dhcp22.suse.cz>
In-Reply-To: <20170310144728.GL3753@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org

On 03/10/2017 03:47 PM, Michal Hocko wrote:
> On Fri 10-03-17 22:40:14, Wu Fengguang wrote:
>> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-4.10
>> head:   7408941b46e4595206353d4028b91e04a3e0f65b
>> commit: 3f045d684db15fb0160bc0166645b16ab6b19bf6 [474/475] arch: add ARCH_HAS_SET_MEMORY config
>> config: x86_64-allyesdebian (attached as .config)
>> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
>> reproduce:
>>          git checkout 3f045d684db15fb0160bc0166645b16ab6b19bf6
>>          # save the attached .config to linux build tree
>>          make ARCH=x86_64
>>
>> All errors (new ones prefixed by >>):
>
> This is probably my fault when I was constructing the mm git tree. The
> treewide patchset was a bit of an PITA to apply correctly and I might
> have forgotten to add some dependencies. Daniel you can ignore this
> report and I will try to resolve this.

Ok, thanks for letting me know, Michal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
