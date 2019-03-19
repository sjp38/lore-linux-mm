Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C28C5C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 17:12:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A27B20872
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 17:12:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A27B20872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 146B56B0006; Tue, 19 Mar 2019 13:12:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11E366B0007; Tue, 19 Mar 2019 13:12:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00C366B0008; Tue, 19 Mar 2019 13:12:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id AFD776B0006
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 13:12:54 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d2so23532216pfn.2
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 10:12:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=n+NhegeaRhEsHWKtS08SfzTOhzjvH4qeOj1eh1Z2n+w=;
        b=bCkoYoYwfOpG9vSms9N1EIXQZAgFj9wzACNPCbFpqVWWlvQyxq2UEClT6i9LNaF+9/
         8h7y+GmIcp1SgBbjA+uIMuD0t30JWbXrSTz6oUH9T6v4KtZMl0CSi0AIZT+TSaeT7TjL
         zb+/Hd6KurPZnjEAcdlt0LAyjBMfp9XUQGOj636bYPJQ8MQYXZ69HVDZduDjEgf+PeUe
         SZvAH8JvfGWtWGhsSly93C08k1gIyLNEemX6wcUO4Cj/bjhRaw7IqayMAy1/wjFz8uXb
         556HHEMUCLFAZMzJSzdmfJGhkzbbFqqPR0NLOhCdv0+6eLMWI55flhwDeYhc15pdDW5K
         NGhQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAWH6P8qWLzxrbrTQ54IeVrtXobdZoG92FDh3jpTOX7cJfbZEqzo
	/FfC3CkV4nkuV4axmyEI5UedBnHIyB9qNo4Mj/WLrM7+7XhZCmq8eW2WfE6EJhMsNZ8JZHvESQ/
	7TaynedYQP5CEfYx3agSXDq/ZFTBvWyr8VrwZxDyaKeJG6njUJCjGjdap99GLYuBkjw==
X-Received: by 2002:a63:4550:: with SMTP id u16mr2747114pgk.73.1553015574316;
        Tue, 19 Mar 2019 10:12:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyD5pq9m8MRLvF9bM6qcOcavxJJVJ1YseNEHXXHoui94NqkhZkSagZ2055d+ctZbDgDcb3R
X-Received: by 2002:a63:4550:: with SMTP id u16mr2747042pgk.73.1553015573326;
        Tue, 19 Mar 2019 10:12:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553015573; cv=none;
        d=google.com; s=arc-20160816;
        b=ssMhflqpv6yi0y+GW4sJRpan0E2A602sapyZBqpcOz0yUTFV8iWLwn02gtB3ASOUeu
         4uISgmDeaoMp+caQ6/iRzY/wgb1LGP5IWZOHzHcioeUEL0d1mZWaJHGQNOaEka56dw7p
         9+bkWg1ikAFKVz/f9wuYbNw7ov7of8plRpOYhty3C9xzyxo+xiploibzfTupRG/JON9B
         bexxKJrZ3hlKYmS9oruI3je5uCmOOUZDUVUd/UMGHQN0z5ePeUHoFBj1NsniADpueMnH
         Uqz0CtVdIeBHGuGiKenilVOAK5PumCKOpw5rNRYl0+Prv+YJC7uA/R2oP9t5LGHx8oYJ
         sdTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=n+NhegeaRhEsHWKtS08SfzTOhzjvH4qeOj1eh1Z2n+w=;
        b=jbb1sprclPNe2kVtzrNo4Xh4ql1zHLLOBAS1NGXUY1M6+aFlxRKT8XS5SyGrQTTYtN
         Kn+RIoMtTbuQIgJdSOO7OJ8mKzHdXdJQHky6W8oKUG3XnbCkz8rRHFCv0+F2nQdTdMge
         PMg/Rd9OVC0xyeGz4WVe/EJBTUMvquBh7kn9f5R63ialPhlKvT02oifIIu+lq/DRNc7x
         5AxER9MxHwf7+6rtUEbOkYdFnuPRjHJie1wXffLadJ/tk1xpkQgKtxEBv62lJvvFfs/x
         kxOETqz3+jccSrhXLBlANSJQdDW2/CKamJKkpLZcHJENiSIki9ap11qx8VwHvtBHcwiu
         E7lA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d186si12497050pfg.50.2019.03.19.10.12.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 10:12:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 9E79E3B2C;
	Tue, 19 Mar 2019 17:12:52 +0000 (UTC)
Date: Tue, 19 Mar 2019 10:12:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Felix Kuehling
 <Felix.Kuehling@amd.com>, Christian =?ISO-8859-1?Q?K=F6nig?=
 <christian.koenig@amd.com>, Ralph Campbell <rcampbell@nvidia.com>, John
 Hubbard <jhubbard@nvidia.com>, Jason Gunthorpe <jgg@mellanox.com>, Dan
 Williams <dan.j.williams@intel.com>, Alex Deucher
 <alexander.deucher@amd.com>
Subject: Re: [PATCH 00/10] HMM updates for 5.1
Message-Id: <20190319101249.d2076f4bacbef948055ae758@linux-foundation.org>
In-Reply-To: <20190319165802.GA3656@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
	<20190313012706.GB3402@redhat.com>
	<20190313091004.b748502871ba0aa839b924e9@linux-foundation.org>
	<20190318170404.GA6786@redhat.com>
	<20190319094007.a47ce9222b5faacec3e96da4@linux-foundation.org>
	<20190319165802.GA3656@redhat.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Mar 2019 12:58:02 -0400 Jerome Glisse <jglisse@redhat.com> wrote:

> > So I think I'll throw up my hands, drop them all and shall await
> > developments :(
> 
> What more do you want to see ? I can repost with the ack already given
> and the improve commit wording on some of the patch. But from user point
> of view nouveau is already upstream, ODP RDMA depends on this patchset
> and is posted and i have given link to it. amdgpu is queue up. What more
> do i need ?

I guess I can ignore linux-next for a few days.  

Yes, a resend against mainline with those various updates will be
helpful.  Please go through the various fixes which we had as well:


mm-hmm-use-reference-counting-for-hmm-struct.patch
mm-hmm-do-not-erase-snapshot-when-a-range-is-invalidated.patch
mm-hmm-improve-and-rename-hmm_vma_get_pfns-to-hmm_range_snapshot.patch
mm-hmm-improve-and-rename-hmm_vma_fault-to-hmm_range_fault.patch
mm-hmm-improve-driver-api-to-work-and-wait-over-a-range.patch
mm-hmm-improve-driver-api-to-work-and-wait-over-a-range-fix.patch
mm-hmm-improve-driver-api-to-work-and-wait-over-a-range-fix-fix.patch
mm-hmm-add-default-fault-flags-to-avoid-the-need-to-pre-fill-pfns-arrays.patch
mm-hmm-add-an-helper-function-that-fault-pages-and-map-them-to-a-device.patch
mm-hmm-support-hugetlbfs-snap-shoting-faulting-and-dma-mapping.patch
mm-hmm-allow-to-mirror-vma-of-a-file-on-a-dax-backed-filesystem.patch
mm-hmm-allow-to-mirror-vma-of-a-file-on-a-dax-backed-filesystem-fix.patch
mm-hmm-allow-to-mirror-vma-of-a-file-on-a-dax-backed-filesystem-fix-2.patch
mm-hmm-add-helpers-for-driver-to-safely-take-the-mmap_sem.patch

Also, the discussion regarding [07/10] is substantial and is ongoing so
please let's push along wth that.

What is the review/discussion status of "[PATCH 09/10] mm/hmm: allow to
mirror vma of a file on a DAX backed filesystem"?

