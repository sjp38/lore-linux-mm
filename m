Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A956FC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 09:42:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CB352086C
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 09:42:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CB352086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A05EB8E006A; Thu, 21 Feb 2019 04:42:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B6288E0002; Thu, 21 Feb 2019 04:42:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A5968E006A; Thu, 21 Feb 2019 04:42:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2DAE88E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 04:42:30 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id f2so6295688edm.18
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 01:42:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=ktMUmPflYsWSWqWK/oOId4wNAiuX77IRqa3q7KI9Wpo=;
        b=GULHM0IDYbEjES39yYdQ7cOF8i6UB6PcpAEX8/8TAJdrZ8fskkX3Gi9rn/unVedYOm
         s6YlpiZAtJiFq21gdCRtHaTh665N3FNPsfzXYLxJo/jok3gtx5qVhsVymwQWFpa2Jc7B
         w9rGjXLLDEH/x6sOQcqFr7Okg4zkvTPIz+NhHghLhGOQ7VISTMicKbPSu/1xZgILcirc
         9M1gtBozdjVjktVVQ/ITkij946/5BxBNEUT+/897iP9kzTQWH1zy8+5b2qel9Ss7YSqR
         LXyRB/XTbE5EeJm2i7cB6feEvjuFVIUhMPFI2/HP3QbVPlR+v9epcFDhWgyMP9A5iK7z
         5Jdw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AHQUAuYx9kbzRGxbCdWn2+Qq5Xi7gLjVEpHfmSUtll/FQgiCNPm3feIX
	SWQXtIKwwEFdnRbZNmIF/3Nlw8OxTjI29HpJiK/6lGUpgLVXxytQUuRJvQbHqF6qPe8KAUSRfS4
	KF1Hr+F58tFyOcPiLtvLxUZXX8WB8kf0aWBDnIlZJMVhQRg4vyA8Gcu9GFgH2Uc2MLw==
X-Received: by 2002:a05:6402:1351:: with SMTP id y17mr2617818edw.111.1550742149546;
        Thu, 21 Feb 2019 01:42:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibpe5G+lYEslQSFapg7TPusY80/xoYEaj8I4aRnHr5Yrriecqe0FBWnp5YB8b8aJypg7LKf
X-Received: by 2002:a05:6402:1351:: with SMTP id y17mr2617750edw.111.1550742148359;
        Thu, 21 Feb 2019 01:42:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550742148; cv=none;
        d=google.com; s=arc-20160816;
        b=kuuqyJZjB7o6XR8A7atPO6Kd/a2rJQgvry7ELrgosdDgrD/oNt9ViaEjfYy7ZAZpCm
         El3f5jmstmHGPvN4Q6MgT96JmcDO+cPSBadZBo5LmjN9Z7yxvnCdywCoExyxI2GFiX4q
         uNlf/7RbJbC7sqi/n2DerOOE25uQSkNRRfmgQLAMT56WFaFIjKpMT8sGRIJe5EeeQTav
         dSGgoPNxPQVvuyJV2VnkgvcMEnMwKl5VMR9tee4m3JiL2TOq064xtlGXzZRHDHcn/bRd
         5l2TNdn6S2N2HiSobllH7DsfizvDk30NCQs/uf4hKqU1xo4jkqUKeY3xngSl5DEjcYYm
         EXZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=ktMUmPflYsWSWqWK/oOId4wNAiuX77IRqa3q7KI9Wpo=;
        b=kqjQT+YESdTWnzRUMkzddky9IGcsCgcje2rPjdlWN+f/hCblFReA2mcIfeDtmHrEGc
         VAaFvFv+neRGufDY5kpdKM3Jc2fnb3ly8keK0CbddFC6s0XhCGhfDzknTlgMhg4jLP3w
         iYlzhEzrx5zKloTOdiS6atp0VssioOHN6FWGTOc/dVaa5TRd6Lzkwkq6K9HIMIkl9Zoh
         hGXYOG9k+h/2AYvcg9SPvmR7UCr01HjXxijWzpuz5Bi/b4iNvC7d0zFSjqwSECDTk2ZA
         luyWhjLdyayLGKkQ8qWxoKQAXglK9I/ILP97J2UnHMjXhEH/mhqfBPhYFSTHJZtbLT91
         3ZUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id l2si5632977edc.381.2019.02.21.01.42.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 01:42:28 -0800 (PST)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Thu, 21 Feb 2019 10:42:27 +0100
Received: from d104.suse.de (nwb-a10-snat.microfocus.com [10.120.13.202])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Thu, 21 Feb 2019 09:42:17 +0000
From: Oscar Salvador <osalvador@suse.de>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	mhocko@suse.com,
	david@redhat.com,
	mike.kravetz@oracle.com,
	Oscar Salvador <osalvador@suse.de>
Subject: [RFC PATCH] mm,memory_hotplug: Unlock 1GB-hugetlb on x86_64
Date: Thu, 21 Feb 2019 10:42:12 +0100
Message-Id: <20190221094212.16906-1-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On x86_64, 1GB-hugetlb pages could never be offlined due to the fact
that hugepage_migration_supported() returned false for PUD_SHIFT.
So whenever we wanted to offline a memblock containing a gigantic
hugetlb page, we never got beyond has_unmovable_pages() check.
This changed with [1], where now we also return true for PUD_SHIFT.

After that patch, the check in has_unmovable_pages() and scan_movable_pages()
returned true, but we still had a final barrier in do_migrate_range():

if (compound_order(head) > PFN_SECTION_SHIFT) {
	ret = -EBUSY;
	break;
}

This is not really nice, and we do not really need it.
It is perfectly possible to migrate a gigantic page as long as another node has
a spare gigantic page for us.
In alloc_huge_page_nodemask(), we calculate the __real__ number of free pages,
and if any, we try to dequeue one from another node.

This all works fine when we do have another node with a spare gigantic page,
but if that is not the case, alloc_huge_page_nodemask() ends up calling
alloc_migrate_huge_page() which bails out if the wanted page is gigantic.
That is mainly because finding a 1GB (or even 16GB on powerpc) contiguous
memory is quite unlikely when the system has been running for a while.

In that situation, we will keep looping forever because scan_movable_pages()
will give us the same page and we will fail again because there is no node
where we can dequeue a gigantic page from.
This is not nice, and I wish we could differentiate a fatal error from a
transient error in do_migrate_range()->migrate_pages(), but I do not really
see a way now.

Anyway, I would tend say that this is the administrator's job, to make sure
that the system can keep up with the memory to be offlined, so that would mean
that if we want to use gigantic pages, make sure that the other nodes have at
least enough gigantic pages to keep up in case we need to offline memory.

Just for the sake of completeness, this is one of the tests done:

 # echo 1 > /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/nr_hugepages
 # echo 1 > /sys/devices/system/node/node2/hugepages/hugepages-1048576kB/nr_hugepages

 # cat /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/nr_hugepages
   1
 # cat /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/free_hugepages
   1

 # cat /sys/devices/system/node/node2/hugepages/hugepages-1048576kB/nr_hugepages
   1
 # cat /sys/devices/system/node/node2/hugepages/hugepages-1048576kB/free_hugepages
   1

 (hugetlb1gb is a program that maps 1GB region using MAP_HUGE_1GB)

 # numactl -m 1 ./hugetlb1gb
 # cat /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/free_hugepages
   0
 # cat /sys/devices/system/node/node2/hugepages/hugepages-1048576kB/free_hugepages
   1

 # offline node1 memory
 # cat /sys/devices/system/node/node2/hugepages/hugepages-1048576kB/free_hugepages
   0

[1] https://lore.kernel.org/patchwork/patch/998796/

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/memory_hotplug.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d5f7afda67db..04f6695b648c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1337,8 +1337,7 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
 		if (!PageHuge(page))
 			continue;
 		head = compound_head(page);
-		if (hugepage_migration_supported(page_hstate(head)) &&
-		    page_huge_active(head))
+		if (page_huge_active(head))
 			return pfn;
 		skip = (1 << compound_order(head)) - (page - head);
 		pfn += skip - 1;
@@ -1378,10 +1377,6 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 
 		if (PageHuge(page)) {
 			struct page *head = compound_head(page);
-			if (compound_order(head) > PFN_SECTION_SHIFT) {
-				ret = -EBUSY;
-				break;
-			}
 			pfn = page_to_pfn(head) + (1<<compound_order(head)) - 1;
 			isolate_huge_page(head, &source);
 			continue;
-- 
2.13.7

