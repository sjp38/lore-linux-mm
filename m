Return-Path: <SRS0=HgWV=RT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E54EC4360F
	for <linux-mm@archiver.kernel.org>; Sat, 16 Mar 2019 09:39:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E93B2218E0
	for <linux-mm@archiver.kernel.org>; Sat, 16 Mar 2019 09:39:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E93B2218E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D80A6B02D3; Sat, 16 Mar 2019 05:39:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 587E66B02D4; Sat, 16 Mar 2019 05:39:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44FB96B02D5; Sat, 16 Mar 2019 05:39:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 14E1B6B02D3
	for <linux-mm@kvack.org>; Sat, 16 Mar 2019 05:39:05 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id x207so4544661vke.11
        for <linux-mm@kvack.org>; Sat, 16 Mar 2019 02:39:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=7lAviSext5DtrcF4EmR7x+P2EdaHXO7hfOqI+dkx7mI=;
        b=eiVSITKJ17m5VhXXOly3isAL+e0qCIM5NK6NlLKA0UdPIUfylMYPYqU3pnmKTDoPrR
         Q2APIj1HK9ooSaNcWeFZyeUpUXsaZNKZF4m0kWAEbUTKcuD2IN7as5+50wPDPUxCUZT6
         Aw+DHabpDfJ6YxJENVVqu7d1D6WamLzsD4Z7rdfRd2FaTmNb4Hxued1fOzWHcMRnsq1r
         Pfl9H/6B9Vbsjz6XZY/B5OfMvnLOUzwK1ejjLGGE1eCldDwivhxdlm3Vaap5Mrrq0rmn
         MsafcCFdtUJN/Ahc6m/+fw/TWsW7G8ooyF3yBelU1PabrFXzof/7SnrD+r7GG1yheb2t
         SApg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: APjAAAUZA172viWSUfHaAM5TGenKB2njOqz/hWnanf6GrEWP1O91YVD0
	I6W0lou4+YeeqcjaDfCoHVDADSa4+Ly+gT9bhh1KGrwJSWtH8DXKcP7PE6FqALjmXJ6qNwMovxg
	1cFuoarEbyHoH7/5vD0vdCZBGn535hAUmnH9xB56+VWZ2EIjhsIXhBholzwcT9Lm3jw==
X-Received: by 2002:ab0:4a1:: with SMTP id 30mr1973709uaw.86.1552729144692;
        Sat, 16 Mar 2019 02:39:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyJK4ZJcHvxS6xIqEvPpiJuC9fpYM+5XRQN6cF8OQgmnNO8oOgnTnc+qT3ghy38Gke8F/rR
X-Received: by 2002:ab0:4a1:: with SMTP id 30mr1973679uaw.86.1552729143768;
        Sat, 16 Mar 2019 02:39:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552729143; cv=none;
        d=google.com; s=arc-20160816;
        b=hIq4KCXurueYPa801eUmcpISn4Et26hd1NlpbaGZQ4BqyiWFsay692ta6efbutb+vk
         YOCjWpt4xg6ZpHJxJtFnosTlSA2HeTpmLVIxo84ONv0bau3APKoPTfQFtYBVvX74uW44
         ylo1uDnBakxJR3t1cKL25uiqUteJaFRdf6k+h1wmvNu4Q2TNg4HjKux1LU5lPl+cA6o1
         aMxJfh+1wgeSJqc/abKUS49H/tdC7qvmSC2p6Eik+yvuCnkPZA+NMjC7X7sqlGmOWfTx
         GlS+aP+Xt9eWjTKqVi+FtayJpZcx4vQe7RwScgH+4zb3ZRvBWfCMgfsKyUK2fjtWUc3D
         ahAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=7lAviSext5DtrcF4EmR7x+P2EdaHXO7hfOqI+dkx7mI=;
        b=mztYQMr9CMZw7DZJdiwbQc6w66jT/DM6yi485wVy07gIFVWQocsXSV+BzAezdtaRSv
         Iik6t747HyvP5J6ec5zS7KV4IasX99o0UEKIO+edI6T6Id9EekoVG1e0Xw1aSY1HcT6d
         9FxNqnUwNoD2bkLjME15+rfxySkK2612xSyOSYUlr3onCufmNWeEBfyv0iNv2xGT1VYd
         GvZrK/QUQbYayY33WTmiU6qTOlj3mA1wNsSyoJl766IoYvVmZBmpp18parFFGM5w92nN
         HvYY1ed+B7E30TSXtgHd+5h0Gxrboipj+7g3/itjIhYcBS5JzC+59lmO3omsO9M/Btdb
         ayng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id v6si148848uac.17.2019.03.16.02.39.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Mar 2019 02:39:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS405-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 2CADE823164DF3D7D755;
	Sat, 16 Mar 2019 17:38:59 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS405-HUB.china.huawei.com
 (10.3.19.205) with Microsoft SMTP Server id 14.3.408.0; Sat, 16 Mar 2019
 17:38:55 +0800
Message-ID: <5C8CC42E.1090208@huawei.com>
Date: Sat, 16 Mar 2019 17:38:54 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: Andrea Arcangeli <aarcange@redhat.com>
CC: Mike Rapoport <rppt@linux.vnet.ibm.com>, Peter Xu <peterx@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov
	<dvyukov@google.com>, syzbot
	<syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com>, Michal Hocko
	<mhocko@kernel.org>, <cgroups@vger.kernel.org>, Johannes Weiner
	<hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM
	<linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, David Rientjes
	<rientjes@google.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox
	<willy@infradead.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka
	<vbabka@suse.cz>
Subject: Re: KASAN: use-after-free Read in get_mem_cgroup_from_mm
References: <00000000000006457e057c341ff8@google.com> <5C7BFE94.6070500@huawei.com> <CACT4Y+Z+CH0UTdSz-w_woMPrBwg-GuobV1Su4qd9ReffTkyfVg@mail.gmail.com> <5C7D2F82.40907@huawei.com> <CACT4Y+agwaszODNGJHCqn4fSk4Le9exn3Cau0nornJ0RaTpDJw@mail.gmail.com> <5C7D4500.3070607@huawei.com> <CACT4Y+b6y_3gTpR8LvNREHOV0TP7jB=Zp1L03dzpaz_SaeESng@mail.gmail.com> <5C7E1A38.2060906@huawei.com> <20190306020540.GA23850@redhat.com> <5C821550.50506@huawei.com> <20190315213944.GD9967@redhat.com>
In-Reply-To: <20190315213944.GD9967@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/3/16 5:39, Andrea Arcangeli wrote:
> On Fri, Mar 08, 2019 at 03:10:08PM +0800, zhong jiang wrote:
>> I can reproduce the issue in arm64 qemu machine.  The issue will leave after applying the
>> patch.
>>
>> Tested-by: zhong jiang <zhongjiang@huawei.com>
> Thanks a lot for the quick testing!
>
>> Meanwhile,  I just has a little doubt whether it is necessary to use RCU to free the task struct or not.
>> I think that mm->owner alway be NULL after failing to create to process. Because we call mm_clear_owner.
> I wish it was enough, but the problem is that the other CPU may be in
> the middle of get_mem_cgroup_from_mm() while this runs, and it would
> dereference mm->owner while it is been freed without the call_rcu
> affter we clear mm->owner. What prevents this race is the
As you had said, It would dereference mm->owner after we clear mm->owner.

But after we clear mm->owner,  mm->owner should be NULL.  Is it right?

And mem_cgroup_from_task will check the parameter. 
you mean that it is possible after checking the parameter to  clear the owner .
and the NULL pointer will trigger. :-(

Thanks,
zhong jiang
> rcu_read_lock() in get_mem_cgroup_from_mm() and the corresponding
> call_rcu to free the task struct in the fork failure path (again only
> if CONFIG_MEMCG=y is defined). Considering you can reproduce this tiny
> race on arm64 qemu (perhaps tcg JIT timing variantions helps?), you
> might also in theory be able to still reproduce the race condition if
> you remove the call_rcu from delayed_free_task and you replace it with
> free_task.
>
> .
>


