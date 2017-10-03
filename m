Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DAEE76B0038
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 21:22:48 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y77so15395095pfd.2
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 18:22:48 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id v2si8733796plp.87.2017.10.02.18.22.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 02 Oct 2017 18:22:47 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v2 1/1] mm: only dispaly online cpus of the numa node
In-Reply-To: <1506678805-15392-2-git-send-email-thunder.leizhen@huawei.com>
References: <1506678805-15392-1-git-send-email-thunder.leizhen@huawei.com> <1506678805-15392-2-git-send-email-thunder.leizhen@huawei.com>
Date: Tue, 03 Oct 2017 12:22:44 +1100
Message-ID: <8760bxdnyz.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhen Lei <thunder.leizhen@huawei.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-api <linux-api@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm <linux-mm@kvack.org>
Cc: Tianhong Ding <dingtianhong@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Libin <huawei.libin@huawei.com>, Kefeng Wang <wangkefeng.wang@huawei.com>

Zhen Lei <thunder.leizhen@huawei.com> writes:

> When I executed numactl -H(which read /sys/devices/system/node/nodeX/cpumap
> and display cpumask_of_node for each node), but I got different result on
> X86 and arm64. For each numa node, the former only displayed online CPUs,
> and the latter displayed all possible CPUs. Unfortunately, both Linux
> documentation and numactl manual have not described it clear.

FWIW powerpc happens to implement the x86 behaviour, online CPUs only.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
