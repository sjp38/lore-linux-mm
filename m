Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93AE6C282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 07:27:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D07D20870
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 07:27:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D07D20870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED9CB6B000A; Mon,  8 Apr 2019 03:27:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E899F6B000E; Mon,  8 Apr 2019 03:27:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D524E6B0266; Mon,  8 Apr 2019 03:27:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9E2416B000A
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 03:27:33 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p6so2296075eds.21
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 00:27:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ARHp8JKZ9oub/xFz030DXfO1+IIX59DpRhC+CW/6ClE=;
        b=t6/8a9/B7UxuGT+czBdnmjzn6TBRCg19yd9hyC4WVRLsAaueYqiES+ohxDrgSW6N9R
         2H4UOMEQA50bZ2k/wJnG4zQSg48qXPoUbLI/vq3hnUI5Ps7x3lasgIQKJluU8hp6FN2m
         dffXOiwWmuOwJj+Y/Lwl3Wt79wE/9Vv0n49eQW9viIBg2qgFH274sj7cQ20fpi0tckJE
         HMVdZbFGTqPR2ZNCr3wMu770gnKzN7u2B5/K9MwCNrRd1REH/a3dXQXbNZdSisIGHjIY
         Pdi5giih87D0VQsFeMBmq/9OfPpmyB+abiJhYWprXuXtIr8xyAws36koMd3UpA73uZb0
         VqIg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVee8Uq4zLb6anID/WhzBr1Zq50eGJk2y13PSvKQYvVTHJuC8u7
	KRrv4dxJNxAeWnnWx7VdLSD8+Sz2WFSlmQK/scF1W0vVUgqv1lHsIcJmF01FUZrlK6/XpfORmv/
	yPFejtOGmbD4zVoDJSv44J7FvKtwXa78dRz/54JeuHtPkfl8xmMZ7rBN20OVtTJr1/A==
X-Received: by 2002:a17:906:b742:: with SMTP id fx2mr15848092ejb.6.1554708453193;
        Mon, 08 Apr 2019 00:27:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyATCSW5EAk8KqcMYWJ4/Q4D999wOiWLaoZXiECCIAhsXhUTdyPoTcCpR+DfTf8IxdBOhkm
X-Received: by 2002:a17:906:b742:: with SMTP id fx2mr15848069ejb.6.1554708452528;
        Mon, 08 Apr 2019 00:27:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554708452; cv=none;
        d=google.com; s=arc-20160816;
        b=sfjJUxG9MBMKfgRY5VimRY6esE+OdprqJFI39lNV6SL5/Vpwj3J8NngiE9NZsQGNlZ
         J6p/WMcc59bo973RFyMpYvxlgwh3fPrTw386Za+EPVlrx6qNPp90M+4EJElDdaIH3iOa
         m+fzdGrqOL8holi7LbyHXGPz3kNTaowpURnm4zLBPTHOpnv8u/RtXWsMkGl5f8hvHPlr
         Ssd4Sh/iApKZYTAT3uSu9pLdY/OAD7HRXRlTlJu3OISkAcwdAjf5qDOPcjiqOqgDITfj
         PffLBg5qACus4Dmn5emjFPmbGlacvQLcqoiDl6guHaJVReSOqH42OFbPWJ0VuPikbD+4
         +PmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ARHp8JKZ9oub/xFz030DXfO1+IIX59DpRhC+CW/6ClE=;
        b=b5KL5kXGiI8yf4O8CpYvyBCZ19+I0R1C6T2SAKJBzOwFlN8OS/RtsliZYxYx7l2pop
         RZwqdeacsdGTSsDkNfVXFp1MJ+HnGyqjw0rkf6zOYvQjJp0M+5tg/RrnElngoOYyV7++
         CPsvdlQ6wNBpx5rZ5PL9fe2WTCDgPv/aiQ73uEyDc6eI+yaA7kPXClb5vCj7PQv5eEWw
         1MOyxnlyaQcrO+LpkHVABhl1Hvno+QJNS9f7+1kPY0IU+Y9RnuWXrHiShIW+zrnKIcEh
         egGxNGmdkFznWTJv9ncX98ksW+Ep7gTv1DTAttDdpyc21MauNflhuh+UJR6F5BUDBGMz
         IAtg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (charybdis-ext.suse.de. [195.135.221.2])
        by mx.google.com with ESMTP id s26si3185936ejx.262.2019.04.08.00.27.32
        for <linux-mm@kvack.org>;
        Mon, 08 Apr 2019 00:27:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id A8CB64890; Mon,  8 Apr 2019 09:27:31 +0200 (CEST)
Date: Mon, 8 Apr 2019 09:27:31 +0200
From: Oscar Salvador <osalvador@suse.de>
To: zhong jiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, rafael@kernel.org, david@redhat.com,
	rafael.j.wysocki@intel.com, mhocko@suse.com, vbabka@suse.cz,
	iamjoonsoo.kim@lge.com, bsingharora@gmail.com,
	gregkh@linuxfoundation.org, yangyingliang@huawei.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [RESENT PATCH] mm/memory_hotplug: Do not unlock when fails to
 take the device_hotplug_lock
Message-ID: <20190408072723.vbwtc5mruvx3un35@d104.suse.de>
References: <1554696437-9593-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1554696437-9593-1-git-send-email-zhongjiang@huawei.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 08, 2019 at 12:07:17PM +0800, zhong jiang wrote:
> When adding the memory by probing memory block in sysfs interface, there is an
> obvious issue that we will unlock the device_hotplug_lock when fails to takes it.
> 
> That issue was introduced in Commit 8df1d0e4a265
> ("mm/memory_hotplug: make add_memory() take the device_hotplug_lock")
> 
> We should drop out in time when fails to take the device_hotplug_lock.
> 
> Fixes: 8df1d0e4a265 ("mm/memory_hotplug: make add_memory() take the device_hotplug_lock")
> Reported-by: Yang yingliang <yangyingliang@huawei.com>
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3

