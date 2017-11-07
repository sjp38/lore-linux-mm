Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 01E28280265
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 09:54:50 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id f16so2476491ioe.1
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 06:54:49 -0800 (PST)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id h67si1565253ita.4.2017.11.07.06.54.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 06:54:48 -0800 (PST)
Date: Tue, 7 Nov 2017 08:54:46 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH RFC v2 4/4] mm/mempolicy: add nodes_empty check in
 SYSC_migrate_pages
In-Reply-To: <a4f1212f-3903-abbc-772a-1ddee6f7f98b@huawei.com>
Message-ID: <alpine.DEB.2.20.1711070851560.18776@nuc-kabylake>
References: <1509099265-30868-1-git-send-email-xieyisheng1@huawei.com> <1509099265-30868-5-git-send-email-xieyisheng1@huawei.com> <dccbeccc-4155-94a8-0e67-b7c28238896d@suse.cz> <bc57f574-92f2-0b69-4717-a1ec7170387c@huawei.com> <d774ecf6-5e7b-e185-85a0-27bf2bcacfb4@suse.cz>
 <alpine.DEB.2.20.1711060926001.9015@nuc-kabylake> <a4f1212f-3903-abbc-772a-1ddee6f7f98b@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tanxiaojun@huawei.com, linux-api@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

On Tue, 7 Nov 2017, Yisheng Xie wrote:

> On 2017/11/6 23:29, Christopher Lameter wrote:
> > On Mon, 6 Nov 2017, Vlastimil Babka wrote:
> >
> >> I'm not sure what exactly is the EPERM intention. Should really the
> >> capability of THIS process override the cpuset restriction of the TARGET
> >> process? Maybe yes. Then, does "insufficient privilege (CAP_SYS_NICE) to
> >
> > CAP_SYS_NICE never overrides cpuset restrictions. The cap can be used to
> > migrate pages that are *also* mapped by other processes (and thus move
> > pages of another process which may have different cpu set restrictions!).
>
> So you means the specified nodes should be a subset of target cpu set, right?

The specified nodes need to be part of the *current* cpu set.

Migrate pages moves the pages of a single process there is no TARGET
process.

Thus thehe *target* nodes need to be a subset of the current cpu set.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
