Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 582E16B02A2
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 06:34:16 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id a125so1821528ita.8
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 03:34:16 -0800 (PST)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id k191si1156837itb.7.2017.11.07.03.34.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Nov 2017 03:34:14 -0800 (PST)
Subject: Re: [PATCH RFC v2 4/4] mm/mempolicy: add nodes_empty check in
 SYSC_migrate_pages
References: <1509099265-30868-1-git-send-email-xieyisheng1@huawei.com>
 <1509099265-30868-5-git-send-email-xieyisheng1@huawei.com>
 <dccbeccc-4155-94a8-0e67-b7c28238896d@suse.cz>
 <bc57f574-92f2-0b69-4717-a1ec7170387c@huawei.com>
 <d774ecf6-5e7b-e185-85a0-27bf2bcacfb4@suse.cz>
 <alpine.DEB.2.20.1711060926001.9015@nuc-kabylake>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <a4f1212f-3903-abbc-772a-1ddee6f7f98b@huawei.com>
Date: Tue, 7 Nov 2017 19:23:52 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1711060926001.9015@nuc-kabylake>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: akpm@linux-foundation.org, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tanxiaojun@huawei.com, linux-api@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

hi Christopher and Vlastimil,

Thanks for your comment!
On 2017/11/6 23:29, Christopher Lameter wrote:
> On Mon, 6 Nov 2017, Vlastimil Babka wrote:
> 
>> I'm not sure what exactly is the EPERM intention. Should really the
>> capability of THIS process override the cpuset restriction of the TARGET
>> process? Maybe yes. Then, does "insufficient privilege (CAP_SYS_NICE) to
> 
> CAP_SYS_NICE never overrides cpuset restrictions. The cap can be used to
> migrate pages that are *also* mapped by other processes (and thus move
> pages of another process which may have different cpu set restrictions!).

So you means the specified nodes should be a subset of target cpu set, right?

Thanks
Yisheng Xie
> The cap should not allow migrating pages to nodes that are not allowed by
> the cpuset of the current process.
> 
> 
> 
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
