Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7552FC04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 14:31:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C7F9208C3
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 14:31:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qOlNtK75"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C7F9208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CF296B0003; Thu,  9 May 2019 10:31:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57F066B0006; Thu,  9 May 2019 10:31:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 448C26B0007; Thu,  9 May 2019 10:31:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id EB83C6B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 10:31:55 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x16so1642638edm.16
        for <linux-mm@kvack.org>; Thu, 09 May 2019 07:31:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=28M3/Gt0muyIKgyfcpD9ysscEUSK1ZnFipvrQH7okoo=;
        b=oGWepqeUFZUUZju8ACGXxmBdSZ+aeP0cJogCqz40gRDWypFh3VBhWJrchV7HwS5MNI
         ZXppgI4LnQKRMgeZbOJeAy/n84b+LHc8nQezdcYv4Rt9ehvcxF2M1O9N3LuCiodtraK2
         YB4kz/wHk3oXNcZ3KLvsYNLFz9g7zHEG2sLb2t+3aA1oVO3ZlI6jzIbsjKrsELAoOY9P
         BIne9GuXz5n2cMW8mzrsy31WsflHwGoS5nZ2I5L9GOAj7tjVw3DrITru7f+xdwY1GZHm
         7nLrhMzzRqXX9CCTGEmwf+r/1uidWahIXYe3+bA+nL1rYUFS6cSG/kpnlUOI05gbE/fk
         mUCA==
X-Gm-Message-State: APjAAAXcKG5BGxDVl3jyQlET9YI9yAuBj4eiN4V8SzvasQiDBr2BsCtN
	VTtBDysVvWzb9/kUGToM6ujAzp8b/lGHvcddDOFo8Dzz7aoLtmYy+J+yhroSwr3IPDsGTWNacGH
	VpmW1izT2XY4uiEoiNIud+lIj7SWg9A8BDIjSNbdd/7c6RMVU0AE0iV6wlGs+3uSKvw==
X-Received: by 2002:a17:906:4bc3:: with SMTP id x3mr3591459ejv.150.1557412315379;
        Thu, 09 May 2019 07:31:55 -0700 (PDT)
X-Received: by 2002:a17:906:4bc3:: with SMTP id x3mr3591375ejv.150.1557412314325;
        Thu, 09 May 2019 07:31:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557412314; cv=none;
        d=google.com; s=arc-20160816;
        b=S2KOB9o/5CVHOo60/DqiyLlfIUUMiHiEZNmGJSjQjc/NUKZEE7ID3UfG1SpBGrEKPo
         33OWIQBhSa/b8pkpFA2GTiBefj9xPEKYoICG1c77eo35sGL4sSVgJNaLjiV9CGDSFbBM
         Dr/tPtCAUqIftQptwxVHii5TPyfiVrhZW/36lVqFk8tKLJCkSo39LwL1CCnqbsgeVSMw
         3gCyR5sMFSQ5xMick/6Cto9nG4fOL8xPl9CammdQjwA2o5wBwtqSz5DjOdItrWrRSfWQ
         2p7WZnRFD1nAwOUyIkxRDDzYraK3NvfQfS9qdqrlS6YNkCcQF+cHU1YJmOi7pAYNlPV2
         qkNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=28M3/Gt0muyIKgyfcpD9ysscEUSK1ZnFipvrQH7okoo=;
        b=xTzYWyI66hApkR6aT4vW4FstnyuUOKhvQ9xoPinR6F9/naIxZYXH1vOfRBKKnNxt/i
         XcJvwJiDBU5PdMyb1buWh3zfpDNi61devWwXgDYbRN4jMQNeOCX8weRZ8rNB8HU9s8HD
         aGocb5N6Y4Q4+xexggJy84TV0uNJ3dAsQUE1r3gGXI2g7eUFJDx2DhAJ/ouHwKYmx+Qv
         Cwqj9QZnONn/vo4sNBeUFO6uisSDouYA9aaD+mCRMbWdt2BSl8/l8r6GynGCoXM6gy/p
         cVFRsGgUZ6mw1lHwvg9PJQf4S59PYE181ne8ntzcTPUAnR++GE1cH1X8O0tewnRKVYKX
         EcnA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qOlNtK75;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c21sor895029ede.28.2019.05.09.07.31.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 May 2019 07:31:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qOlNtK75;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=28M3/Gt0muyIKgyfcpD9ysscEUSK1ZnFipvrQH7okoo=;
        b=qOlNtK752XXn4kkfsFMWyY7kRPfrZUsTtqBPdR/hrsY1mJM2tbu2nhsutSmVVSM1WW
         nXRASbDxRAmYKoGMORG1Srq+QfFSesIFDMzjzchm3j4kE/sLGsIywSyqVlu3Yz91d/8r
         FlEQUB4qvWSHM4vKfCBekEvL6H1BeRT6mMgSjN/ZfvQ7xjppTiRrhRzhd0DiONdD3rHG
         8+F+D+pkIWAxOZxeIGT+39UvOnSIMPWvX3z65R9GJNUd8yqfL58nMe8pY6Q7GvVCzYIM
         6GCvJUep1xdo/Z8mF1dvC94zMfD6T5hlTY7VkMhVkudMpY654rvkzmeZxmnK6kPTSOvF
         yY0g==
X-Google-Smtp-Source: APXvYqzkJhS5L8NnWGrt01x6w71u7E8s0GHuJykWEj8KfZGhfTtKpBAzu9nFzSqSe/2NArkKjIgUMw==
X-Received: by 2002:a50:be48:: with SMTP id b8mr4401819edi.284.1557412313899;
        Thu, 09 May 2019 07:31:53 -0700 (PDT)
Received: from localhost ([185.92.221.13])
        by smtp.gmail.com with ESMTPSA id d11sm623679eda.45.2019.05.09.07.31.52
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 09 May 2019 07:31:52 -0700 (PDT)
Date: Thu, 9 May 2019 14:31:51 +0000
From: Wei Yang <richard.weiyang@gmail.com>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	akpm@linux-foundation.org, Dan Williams <dan.j.williams@intel.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	"mike.travis@hpe.com" <mike.travis@hpe.com>,
	Ingo Molnar <mingo@kernel.org>,
	Andrew Banman <andrew.banman@hpe.com>,
	Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>, Qian Cai <cai@lca.pw>,
	Wei Yang <richard.weiyang@gmail.com>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: Re: [PATCH v2 4/8] mm/memory_hotplug: Create memory block devices
 after arch_add_memory()
Message-ID: <20190509143151.zexjmwu3ikkmye7i@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20190507183804.5512-1-david@redhat.com>
 <20190507183804.5512-5-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190507183804.5512-5-david@redhat.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 07, 2019 at 08:38:00PM +0200, David Hildenbrand wrote:
>Only memory to be added to the buddy and to be onlined/offlined by
>user space using memory block devices needs (and should have!) memory
>block devices.
>
>Factor out creation of memory block devices Create all devices after
>arch_add_memory() succeeded. We can later drop the want_memblock parameter,
>because it is now effectively stale.
>
>Only after memory block devices have been added, memory can be onlined
>by user space. This implies, that memory is not visible to user space at
>all before arch_add_memory() succeeded.
>
>Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>Cc: "Rafael J. Wysocki" <rafael@kernel.org>
>Cc: David Hildenbrand <david@redhat.com>
>Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
>Cc: Andrew Morton <akpm@linux-foundation.org>
>Cc: Ingo Molnar <mingo@kernel.org>
>Cc: Andrew Banman <andrew.banman@hpe.com>
>Cc: Oscar Salvador <osalvador@suse.de>
>Cc: Michal Hocko <mhocko@suse.com>
>Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
>Cc: Qian Cai <cai@lca.pw>
>Cc: Wei Yang <richard.weiyang@gmail.com>
>Cc: Arun KS <arunks@codeaurora.org>
>Cc: Mathieu Malaterre <malat@debian.org>
>Signed-off-by: David Hildenbrand <david@redhat.com>
>---
> drivers/base/memory.c  | 70 ++++++++++++++++++++++++++----------------
> include/linux/memory.h |  2 +-
> mm/memory_hotplug.c    | 15 ++++-----
> 3 files changed, 53 insertions(+), 34 deletions(-)
>
>diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>index 6e0cb4fda179..862c202a18ca 100644
>--- a/drivers/base/memory.c
>+++ b/drivers/base/memory.c
>@@ -701,44 +701,62 @@ static int add_memory_block(int base_section_nr)
> 	return 0;
> }
> 
>+static void unregister_memory(struct memory_block *memory)
>+{
>+	BUG_ON(memory->dev.bus != &memory_subsys);
>+
>+	/* drop the ref. we got via find_memory_block() */
>+	put_device(&memory->dev);
>+	device_unregister(&memory->dev);
>+}
>+
> /*
>- * need an interface for the VM to add new memory regions,
>- * but without onlining it.
>+ * Create memory block devices for the given memory area. Start and size
>+ * have to be aligned to memory block granularity. Memory block devices
>+ * will be initialized as offline.
>  */
>-int hotplug_memory_register(int nid, struct mem_section *section)
>+int hotplug_memory_register(unsigned long start, unsigned long size)

One trivial suggestion about the function name.

For memory_block device, sometimes we use the full name

    find_memory_block
    init_memory_block
    add_memory_block

But sometimes we use *nick* name

    hotplug_memory_register
    register_memory
    unregister_memory

This is a little bit confusion.

Can we use one name convention here? 

[...]

> /*
>@@ -1106,6 +1100,13 @@ int __ref add_memory_resource(int nid, struct resource *res)
> 	if (ret < 0)
> 		goto error;
> 
>+	/* create memory block devices after memory was added */
>+	ret = hotplug_memory_register(start, size);
>+	if (ret) {
>+		arch_remove_memory(nid, start, size, NULL);

Functionally, it works I think.

But arch_remove_memory() would remove pages from zone. At this point, we just
allocate section/mmap for pages, the zones are empty and pages are not
connected to zone.

Function  zone = page_zone(page); always gets zone #0, since pages->flags is 0
at  this point. This is not exact.

Would we add some comment to mention this? Or we need to clean up
arch_remove_memory() to take out __remove_zone()?


>+		goto error;
>+	}
>+
> 	if (new_node) {
> 		/* If sysfs file of new node can't be created, cpu on the node
> 		 * can't be hot-added. There is no rollback way now.
>-- 
>2.20.1

-- 
Wei Yang
Help you, Help me

