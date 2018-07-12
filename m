Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 93F186B0003
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 22:17:53 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q21-v6so17509409pff.4
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 19:17:53 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 186-v6si1333077pff.270.2018.07.11.19.17.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 19:17:52 -0700 (PDT)
Message-ID: <5B46BB46.2080802@intel.com>
Date: Thu, 12 Jul 2018 10:21:58 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v35 1/5] mm: support to get hints of free page blocks
References: <1531215067-35472-1-git-send-email-wei.w.wang@intel.com> <1531215067-35472-2-git-send-email-wei.w.wang@intel.com> <CA+55aFz9a=D-kquM=sG5uhV_HrBAw+VAhcJmtPNz+howy4j9ow@mail.gmail.com> <5B455D50.90902@intel.com> <CA+55aFzqj8wxXnHAdUTiOomipgFONVbqKMjL_tfk7e5ar1FziQ@mail.gmail.com> <20180711092152.GE20050@dhcp22.suse.cz> <CA+55aFwku2tDH4+rfaC67xc4-cEwSrXgnQaci=e2id5ZCRE9JQ@mail.gmail.com>
In-Reply-To: <CA+55aFwku2tDH4+rfaC67xc4-cEwSrXgnQaci=e2id5ZCRE9JQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>
Cc: virtio-dev@lists.oasis-open.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, virtualization <virtualization@lists.linux-foundation.org>, KVM list <kvm@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Michael S. Tsirkin" <mst@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, Rik van Riel <riel@redhat.com>, peterx@redhat.com

On 07/12/2018 12:23 AM, Linus Torvalds wrote:
> On Wed, Jul 11, 2018 at 2:21 AM Michal Hocko <mhocko@kernel.org> wrote:
>> We already have an interface for that. alloc_pages(GFP_NOWAIT, MAX_ORDER -1).
>> So why do we need any array based interface?
> That was actually my original argument in the original thread - that
> the only new interface people might want is one that just tells how
> many of those MAX_ORDER-1 pages there are.
>
> See the thread in v33 with the subject
>
>    "[PATCH v33 1/4] mm: add a function to get free page blocks"
>
> and look for me suggesting just using
>
>      #define GFP_MINFLAGS (__GFP_NORETRY | __GFP_NOWARN |
> __GFP_THISNODE | __GFP_NOMEMALLOC)

Would it be better to remove __GFP_THISNODE? We actually want to get all 
the guest free pages (from all the nodes).

Best,
Wei
