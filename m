Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3EC1B440417
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 10:02:40 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id n137so5784030iod.20
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 07:02:40 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id p97si4801922ioo.92.2017.11.08.07.02.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 07:02:38 -0800 (PST)
Date: Wed, 8 Nov 2017 09:02:36 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH RFC v2 4/4] mm/mempolicy: add nodes_empty check in
 SYSC_migrate_pages
In-Reply-To: <4b08f1e9-5449-6ea2-e7da-65fe5f678683@huawei.com>
Message-ID: <alpine.DEB.2.20.1711080900050.6161@nuc-kabylake>
References: <1509099265-30868-1-git-send-email-xieyisheng1@huawei.com> <1509099265-30868-5-git-send-email-xieyisheng1@huawei.com> <dccbeccc-4155-94a8-0e67-b7c28238896d@suse.cz> <bc57f574-92f2-0b69-4717-a1ec7170387c@huawei.com> <d774ecf6-5e7b-e185-85a0-27bf2bcacfb4@suse.cz>
 <alpine.DEB.2.20.1711060926001.9015@nuc-kabylake> <a4f1212f-3903-abbc-772a-1ddee6f7f98b@huawei.com> <alpine.DEB.2.20.1711070851560.18776@nuc-kabylake> <04e4cb50-8cba-58af-1a5e-61e818cffa70@suse.cz> <alpine.DEB.2.20.1711070948410.19176@nuc-kabylake>
 <4b08f1e9-5449-6ea2-e7da-65fe5f678683@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tanxiaojun@huawei.com, linux-api@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

On Wed, 8 Nov 2017, Yisheng Xie wrote:

> Another case is current process is *not* the same as target process, and
> when current process try to migrate pages of target process from old_nodes
> to new_nodes, the new_nodes should be a subset of target process cpuset.

The caller of migrate_pages should be able to migrate the target process
pages anywhere the caller can allocate memory. If that is outside the
target processes cpuset then that is fine. Pagecache pages that are not
allocated by the target process already are not subject to the target
processes restriction. So this is not that unusual.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
