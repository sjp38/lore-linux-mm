Return-Path: <SRS0=PcJq=O5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63E97C43387
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 19:21:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24AF4218FE
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 19:21:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="cVyLVlWC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24AF4218FE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA5038E000C; Thu, 20 Dec 2018 14:21:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B526D8E0001; Thu, 20 Dec 2018 14:21:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A67DF8E000C; Thu, 20 Dec 2018 14:21:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7C3538E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 14:21:56 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id w18so2916997qts.8
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:21:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:user-agent:date:from
         :to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject:feedback-id;
        bh=w3aqjn3w3cXbm3egXtkjdBiFToH98vSRG9WnJxvEZPo=;
        b=DQgPYnaweZ024fUaJaSOhr39tUjmB6fD0RHBTBPU4dhfkXEEV8YNk0XbHVFMcaUkVP
         L9q+nNY9K5htbRO7epfY68UUmmL5wPV4mg3GOXumPVFklnyGEqEeNx2KSm5S59DscCvp
         mzRRScB+72IEwapZAMQi82gbab+X6JftzpFyfBArs1bGvD/x84hctLHTauI1E4xOLxDX
         NRkDWYJ8FJqLkn/aQFHeH5oNZqfLvP2BnFcCYWG0RkQe5Mq8oKvZHPiF0X9cJrEnSkD9
         +FFhL2FIwYRtUnLEUFiXM21hhZv6bhsdAiKPA6jxa6xZhkT8QR52IoR9v8BSyV+fNbeq
         W7rg==
X-Gm-Message-State: AA+aEWZ1h/hijLXbYOdrUMNySUt9drLJ7t2UhiuvoffRULUy2IeyOFIB
	J/MlXk1zjES583EvCe4fOgq6h0Uiq+Qgom+SBlEdkoMJr2LH/t5Xak9U9HDubvskURsyPTpIVvn
	tA+NSYmNpQtVo4lRBJhcwvfsnlYOvQq/mTSEfrqYUN8q/j/ZVlbgHeCwbd8HKS9g=
X-Received: by 2002:a37:8882:: with SMTP id k124mr25440785qkd.1.1545333716198;
        Thu, 20 Dec 2018 11:21:56 -0800 (PST)
X-Google-Smtp-Source: AFSGD/XtE6cT7yUzAGY2s28Ip5ImRV+sYFVEgVQp7hRUnV2Y8um2qE4fGmKRYpGE72TtOLvcHlXJ
X-Received: by 2002:a37:8882:: with SMTP id k124mr25440760qkd.1.1545333715566;
        Thu, 20 Dec 2018 11:21:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545333715; cv=none;
        d=google.com; s=arc-20160816;
        b=TbFA6QfCEXO466WgiknJkZ3uv2hP1bBBmo0gyhqYZcukZdXaeYhDRgs/SIxStYMUfd
         i9GDu4CweB55HZYQWziFn51qJi7Cdi42sqotzYx7e3PDuZ+Vj46jdqd5IZh4/RoXQ4c7
         tQx5SNanYZaSh9hkorXu8eaqNXm4h3ySfceFLa2QCnDIzQPrkjzlUzfN06pSs80s43Fg
         POd3t0xU5AW3w430UKItDBF01X2se2fN6l7k6viynSSNRHcYvM0kVj3B84PW0jKT1mj3
         U754p3Idi2HzCJdYz0GbQLOZGd6d0JkCS2PTAcKJrCAZCJTzZcsLAIzJLucmkOQ+3usQ
         TSng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:subject:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:to:from:date
         :user-agent:message-id:dkim-signature;
        bh=w3aqjn3w3cXbm3egXtkjdBiFToH98vSRG9WnJxvEZPo=;
        b=XnhMOxPk+G/Oeui8ZA1bO/CrDmhPvn6LNO//W+OFarRwr+hql0P+l1e9QjT7k1MdUf
         AOAt0hvGWeNQlpUe0drdGYsCs5Tu1oBi5a8PRuCX39ZDgXLilk1Io7VySjqpMSJjCg9o
         xPF4zLvfVFOau7vVrCzTML3HnM10bCvMKXNov6+Tqg1OlnjX3sZGX6A2lmUzVZz3dXxN
         HgaUVIoz0kJxG+cnLToHw/wG3pAjSt0yWPR235wmBgdFB5WLE+Afw01TKM1WaWabBST2
         AoV612q2sUg5e1yYF2KYO5GOtv3GCbyc6DkpxZ8BtMD42RnRrDSdZqYEmMXfvTGYHL/q
         oYIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=fail header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=cVyLVlWC;
       spf=pass (google.com: domain of 01000167cd1130c8-c9bebcb9-1f95-4f7c-b24a-90600d56c62f-000000@amazonses.com designates 54.240.9.36 as permitted sender) smtp.mailfrom=01000167cd1130c8-c9bebcb9-1f95-4f7c-b24a-90600d56c62f-000000@amazonses.com
Received: from a9-36.smtp-out.amazonses.com (a9-36.smtp-out.amazonses.com. [54.240.9.36])
        by mx.google.com with ESMTPS id a6si2715313qtj.202.2018.12.20.11.21.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Dec 2018 11:21:55 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000167cd1130c8-c9bebcb9-1f95-4f7c-b24a-90600d56c62f-000000@amazonses.com designates 54.240.9.36 as permitted sender) client-ip=54.240.9.36;
Authentication-Results: mx.google.com;
       dkim=fail header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=cVyLVlWC;
       spf=pass (google.com: domain of 01000167cd1130c8-c9bebcb9-1f95-4f7c-b24a-90600d56c62f-000000@amazonses.com designates 54.240.9.36 as permitted sender) smtp.mailfrom=01000167cd1130c8-c9bebcb9-1f95-4f7c-b24a-90600d56c62f-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1545333715;
	h=Message-Id:Date:From:To:Cc:Cc:Cc:CC:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Subject:Feedback-ID;
	bh=ZC6NB5lKn8jM6W/kwe979AqbHeNIIEDgIRYq8F0S3jo=;
	b=cVyLVlWCMnX/xXwSbAOjGke/AaYduszsLs/wcSBoRGW5RCfHoQOhRZPLy65aov7v
	9F/S49PS1d+goBBjMmRpktLA/MBVFqqHc031bjQtF3/MdMPm1fRkfHVEofYlextIQBK
	fgnfbFMt6KSXHbGnpRm3LWKe9CJGadGv7vXr+1Ps=
Message-ID:
 <01000167cd1130c8-c9bebcb9-1f95-4f7c-b24a-90600d56c62f-000000@email.amazonses.com>
User-Agent: quilt/0.65
Date: Thu, 20 Dec 2018 19:21:55 +0000
From: Christoph Lameter <cl@linux.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
CC: akpm@linux-foundation.org
Cc: Mel Gorman <mel@skynet.ie>
Cc: andi@firstfloor.org
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC 0/7] Slab object migration for xarray V2
X-SES-Outgoing: 2018.12.20-54.240.9.36
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20181220192155.k5n-hY2kUhcNtKH2JyaS3YlvdNAOh5H_lW8Vh-MXWH0@z>

V1->V2:
	- Works now on top of 4.20-rc7
	- A couple of bug fixes


This is a patchset on top of Matthew Wilcox Xarray code and implements
slab object migration for xarray nodes. The migration is integrated into
the defragmetation and shrinking logic of the slab allocator.

Defragmentation will ensure that all xarray slab pages have
less objects available than specified by the slab defrag ratio.

Slab shrinking will create a slab cache with optimal object
density. Only one slab page will have available objects per node.

To test apply this patchset and run a workload that uses lots of radix tree objects


Then go to

/sys/kernel/slab/radix_tree_node

Inspect the number of total objects that the slab can handle

	cat total_objects

qmdr:/sys/kernel/slab/radix_tree_node# cat objects
868 N0=448 N1=168 N2=56 N3=196

And the number of slab pages used for those

	cat slabs

qmdr:/sys/kernel/slab/radix_tree_node# cat slabs
31 N0=16 N1=6 N2=2 N3=7


Perform a cache shrink operation

	echo 1 >shrink


Now see how the slab has changed:

qmdr:/sys/kernel/slab/radix_tree_node# cat slabs
30 N0=15 N1=6 N2=2 N3=7
qmdr:/sys/kernel/slab/radix_tree_node# cat objects
713 N0=349 N1=141 N2=52 N3=171


This is just a barebones approach using a special mode
of the slab migration patchset that does not require refcounts.



If this is acceptable then additional functionality can be added:

1. Migration of objects to a specific node. Not sure how to implement
   that. Using another sysfs field?

2. Dispersion of objects across all nodes (MPOL_INTERLEAVE)

3. Subsystems can request to move an object to a specific node.
   How to design such functionality best?

4. Tying into the page migration and page defragmentation logic so
   that so far unmovable pages that are in the way of creating a
   contiguous block of memory will become movable.
   This would mean checking for slab pages in the migration logic
   and calling slab to see if it can move the page by migrating
   all objects.

This is only possible for xarray for now but it would be worthwhile
to extend this to dentries and inodes.

