Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 186E56B0038
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 10:29:53 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id 72so6398286itl.1
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 07:29:53 -0800 (PST)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id z67si7745427itf.129.2017.11.06.07.29.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 07:29:51 -0800 (PST)
Date: Mon, 6 Nov 2017 09:29:49 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH RFC v2 4/4] mm/mempolicy: add nodes_empty check in
 SYSC_migrate_pages
In-Reply-To: <d774ecf6-5e7b-e185-85a0-27bf2bcacfb4@suse.cz>
Message-ID: <alpine.DEB.2.20.1711060926001.9015@nuc-kabylake>
References: <1509099265-30868-1-git-send-email-xieyisheng1@huawei.com> <1509099265-30868-5-git-send-email-xieyisheng1@huawei.com> <dccbeccc-4155-94a8-0e67-b7c28238896d@suse.cz> <bc57f574-92f2-0b69-4717-a1ec7170387c@huawei.com>
 <d774ecf6-5e7b-e185-85a0-27bf2bcacfb4@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, akpm@linux-foundation.org, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tanxiaojun@huawei.com, linux-api@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

On Mon, 6 Nov 2017, Vlastimil Babka wrote:

> I'm not sure what exactly is the EPERM intention. Should really the
> capability of THIS process override the cpuset restriction of the TARGET
> process? Maybe yes. Then, does "insufficient privilege (CAP_SYS_NICE) to

CAP_SYS_NICE never overrides cpuset restrictions. The cap can be used to
migrate pages that are *also* mapped by other processes (and thus move
pages of another process which may have different cpu set restrictions!).
The cap should not allow migrating pages to nodes that are not allowed by
the cpuset of the current process.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
