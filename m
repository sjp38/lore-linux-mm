Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9FBEB440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 10:46:45 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id i38so9669545iod.10
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 07:46:45 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id v199si6981260ita.7.2017.11.09.07.46.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Nov 2017 07:46:44 -0800 (PST)
Date: Thu, 9 Nov 2017 09:46:42 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH RFC v2 4/4] mm/mempolicy: add nodes_empty check in
 SYSC_migrate_pages
In-Reply-To: <9991dd10-8883-7c82-bb4e-8145ea2b7299@huawei.com>
Message-ID: <alpine.DEB.2.20.1711090946130.12483@nuc-kabylake>
References: <1509099265-30868-1-git-send-email-xieyisheng1@huawei.com> <1509099265-30868-5-git-send-email-xieyisheng1@huawei.com> <dccbeccc-4155-94a8-0e67-b7c28238896d@suse.cz> <bc57f574-92f2-0b69-4717-a1ec7170387c@huawei.com> <d774ecf6-5e7b-e185-85a0-27bf2bcacfb4@suse.cz>
 <alpine.DEB.2.20.1711060926001.9015@nuc-kabylake> <a4f1212f-3903-abbc-772a-1ddee6f7f98b@huawei.com> <alpine.DEB.2.20.1711070851560.18776@nuc-kabylake> <04e4cb50-8cba-58af-1a5e-61e818cffa70@suse.cz> <alpine.DEB.2.20.1711070948410.19176@nuc-kabylake>
 <4b08f1e9-5449-6ea2-e7da-65fe5f678683@huawei.com> <alpine.DEB.2.20.1711080900050.6161@nuc-kabylake> <9991dd10-8883-7c82-bb4e-8145ea2b7299@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tanxiaojun@huawei.com, linux-api@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

On Thu, 9 Nov 2017, Yisheng Xie wrote:

> > The caller of migrate_pages should be able to migrate the target process
> > pages anywhere the caller can allocate memory. If that is outside the
> > target processes cpuset then that is fine. Pagecache pages that are not
> > allocated by the target process already are not subject to the target
> > processes restriction. So this is not that unusual.
>
> So there is no need to check the restriction of target process cpuset, right?
> I hope that I do not miss anything :)

Exactly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
