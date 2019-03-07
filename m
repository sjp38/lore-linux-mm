Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6CA3C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 07:58:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9202D20835
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 07:58:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9202D20835
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2635B8E0003; Thu,  7 Mar 2019 02:58:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 212688E0002; Thu,  7 Mar 2019 02:58:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1020F8E0003; Thu,  7 Mar 2019 02:58:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id D19678E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 02:58:24 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id g24so6623573otq.22
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 23:58:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=O8KcmkCG6648tD1oxTSAjybzMbRUkA7i3ZoZN7G2i9A=;
        b=njqUIjggMy8ZPZMgQPYnEzWX3uS2pqDs/O1iG37/y/1j3YIqeZ4NX4c2ZDfTTvSvg2
         uKg/L0VdgOwkLkyb4JNCmpnUATMcXt7c8ip8Se18Lo6HhGKRSq3n2qQr4rYOOnlWJg88
         uKmnrpsWwJ3vrLuB46Zwk8jdijo2IlTk2/2EGmtMbY+FMFxFIoe9Lq38Tx9kMa4Pde/U
         AOOKgYY5QuRNDsxQEHOB2cheo0Mnl4vSi74b4QoXkgZr4mfzUcR90a4JGtXQD24FSJAX
         gAxhMpxcjmKjLGdJ/nRTNBiMBnHTtp7nketN7JI8wW//KPeCh2Ijn5n1CvsHWd+MiOTo
         RuPw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: APjAAAXAQl0JGrqpG7hYlpFt9pPFUErNAJ4cUnvOkzEic/eGFcIURJqr
	u0rLrMcv6712osS8YWzRcheJ3iJhMC568M7sRIc2yEfP3TCqkgjebOpAlQrRpKcUeS9TprCpZBL
	5LUvXZWBeWdEoCg8umPQIxolm/AlmHYSzXUHCnGNG5CAv4BC66FQ54E5y+Nkt/jyAaw==
X-Received: by 2002:a05:6830:1501:: with SMTP id k1mr7324997otp.245.1551945504537;
        Wed, 06 Mar 2019 23:58:24 -0800 (PST)
X-Google-Smtp-Source: APXvYqzq4GPNjnjlTjQ1rDaecH6BiNgGjCJ54ndo+y3QMoaOhMIrpOgF8Ceu5hvbksrpVrkJv233
X-Received: by 2002:a05:6830:1501:: with SMTP id k1mr7324972otp.245.1551945503762;
        Wed, 06 Mar 2019 23:58:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551945503; cv=none;
        d=google.com; s=arc-20160816;
        b=hN8Gft/HZbivqBMCzeliBMMOISnmpRSAcrx625s72COYH0Tm5znD6w+slHBi3Xq4pO
         oV+JlDMkLROEccn/aptgBSx1+Dc3jlofTELjuTdJbkCsWzLR+msC+WMEXid4OqBOTaPU
         z5rLGUs2T2xkUI8fd3xAgjPAjZNXxrUCjv9ubGw/rjBeaSJU6oKhagLHhIMfFD4ZTrC6
         EQ1AQUNorbfAN/YpKpLlaDCszJav7kNyAwlydWZ0eENAK6ZuhQi5ob+0lTx1Z4xAcnuw
         76P/h6cFOiwiOudBOwOGV0Bh+jqc3Q5BG3ph6b5dIMAK2naTaDhc3Ct8SqPiTfmI4ptj
         N0rQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=O8KcmkCG6648tD1oxTSAjybzMbRUkA7i3ZoZN7G2i9A=;
        b=MuanPiyfI3qINlrdnnTAP40ka5W0H5jEnkLtOARaV0AKX0yx74TRH3kcFS91xyLZ37
         a+8HnvmWZa6eYWFgKpytRGJ4zb/0qUVsHYcrZpdRPSNPVjN7BHPX5gIDWg01IIaRkH8B
         4GQEYDIiLGFJvN/Mw9pClL6t5rUbGnr+G03i6cc1/b3GfFTGkBWANU0fv+P6KWlvLBGe
         z+F6ptUA/DkJwC9Auzr6frIKLjzCkbVe9NKgNb1RM/NoJvxu1MAWoX+WckLjExYfoLKL
         ZEKaQ++OYuODJnRlpc9ZOSvEGqXonVg2zySwsOVIbAZvfpi5dxoFNRSjj5gJZunIAC71
         NXkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id s128si1595380oih.29.2019.03.06.23.58.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 23:58:23 -0800 (PST)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS414-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id ECEA3652F26AB03354C5;
	Thu,  7 Mar 2019 15:58:18 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS414-HUB.china.huawei.com
 (10.3.19.214) with Microsoft SMTP Server id 14.3.408.0; Thu, 7 Mar 2019
 15:58:16 +0800
Message-ID: <5C80CF16.70109@huawei.com>
Date: Thu, 7 Mar 2019 15:58:14 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: Andrea Arcangeli <aarcange@redhat.com>
CC: Peter Xu <peterx@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>, "Dmitry
 Vyukov" <dvyukov@google.com>, syzbot
	<syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com>, Michal Hocko
	<mhocko@kernel.org>, <cgroups@vger.kernel.org>, Johannes Weiner
	<hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM
	<linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, David Rientjes
	<rientjes@google.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox
	<willy@infradead.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka
	<vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: KASAN: use-after-free Read in get_mem_cgroup_from_mm
References: <CACT4Y+agwaszODNGJHCqn4fSk4Le9exn3Cau0nornJ0RaTpDJw@mail.gmail.com> <5C7D4500.3070607@huawei.com> <CACT4Y+b6y_3gTpR8LvNREHOV0TP7jB=Zp1L03dzpaz_SaeESng@mail.gmail.com> <5C7E1A38.2060906@huawei.com> <20190306020540.GA23850@redhat.com> <5C7F6048.2050802@huawei.com> <20190306062625.GA3549@rapoport-lnx> <5C7F7992.7050806@huawei.com> <20190306081201.GC11093@xz-x1> <5C7FC5F4.40903@huawei.com> <20190306182944.GE23850@redhat.com>
In-Reply-To: <20190306182944.GE23850@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/3/7 2:29, Andrea Arcangeli wrote:
> Hello Zhong,
>
> On Wed, Mar 06, 2019 at 09:07:00PM +0800, zhong jiang wrote:
>> The patch use call_rcu to delay free the task_struct, but It is possible to free the task_struct
>> ahead of get_mem_cgroup_from_mm. is it right?
> Yes it is possible to free before get_mem_cgroup_from_mm, but if it's
> freed before get_mem_cgroup_from_mm rcu_read_lock,
> rcu_dereference(mm->owner) will return NULL in such case and there
> will be no problem.
Yes
> The simple fix also clears the mm->owner of the failed-fork-mm before
> doing the call_rcu. The call_rcu delays the freeing after no other CPU
> runs in between rcu_read_lock/unlock anymore. That guarantees that
> those critical section will see mm->owner == NULL if the freeing of
> the task strut already happened.
We has set the mm->owner to NULL when child process fails to fork ahead of freeing
the task struct.

Have those critical section  chance to see the mm->owner, which is not NULL.

I has tested the patch.  Not Oops and panic appear  so far.

Thanks,
zhong jiang
> The solution Mike suggested for this and that we were wondering as
> ideal in the past for the signal issue too, is to move the uffd
> delivery at a point where fork is guaranteed to succeed. We should
> probably try that too to see how it looks like and if it can be done
> in a not intrusive way, but the simple fix that uses RCU should work
> too.
>
> Rolling back in case of errors inside fork itself isn't easily doable:
> the moment we push the uffd ctx to the other side of the uffd pipe
> there's no coming back as that information can reach the userland of
> the uffd monitor/reader thread immediately after. The rolling back is
> really the other thread failing at mmget_not_zero eventually. It's the
> userland that has to rollback in such case when it gets a -ESRCH
> retval.
>
> Note that this fork feature is only ever needed in the non-cooperative
> case, these things never need to happen when userfaultfd is used by an
> app (or a lib) that is aware that it is using userfaultfd.
>
> Thanks,
> Andrea
>
> .
>


