Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 41D296B0038
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 22:55:30 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id w194so9894521vkw.2
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 19:55:30 -0800 (PST)
Received: from mail-vk0-x243.google.com (mail-vk0-x243.google.com. [2607:f8b0:400c:c05::243])
        by mx.google.com with ESMTPS id n25si14745871uab.96.2016.12.13.19.55.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 19:55:29 -0800 (PST)
Received: by mail-vk0-x243.google.com with SMTP id x186so1125009vkd.2
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 19:55:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161213181511.GB2305@redhat.com>
References: <20161213181511.GB2305@redhat.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Wed, 14 Dec 2016 14:55:28 +1100
Message-ID: <CAKTCnzkniWn_ayN9LsXzc9GRBQAaq_gqmvWu0-aELUxkCzkXMA@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Un-addressable device memory and block/fs implications
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, linux-block@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Wed, Dec 14, 2016 at 5:15 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> I would like to discuss un-addressable device memory in the context of
> filesystem and block device. Specificaly how to handle write-back, read,
> ... when a filesystem page is migrated to device memory that CPU can not
> access.
>
> I intend to post a patchset leveraging the same idea as the existing
> block bounce helper (block/bounce.c) to handle this. I believe this is
> worth discussing during summit see how people feels about such plan and
> if they have better ideas.
>
>
Yes, that would be interesting. I presume all of this is for
ZONE_DEVICE and HMM.
I think designing such an interface requires careful thought on tracking pages
to ensure we don't lose writes and also the impact on things like the
writeback subsytem.

>From a HMM perspective and an overall MM perspective, I worry that our
accounting
system is broken with the proposed mirroring and unaddressable memory that
needs to be addressed as well.

It would also be nice to have a discussion on migration patches currently on the
list

1. THP migration
2. HMM migration
3. Async migration

> I also like to join discussions on:
>   - Peer-to-Peer DMAs between PCIe devices
>   - CDM coherent device memory

Yes, this needs discussion. Specifically from is all of CDM memory NORMAL or not
and the special requirements we have today for CDM.

>   - PMEM
>   - overall mm discussions

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
