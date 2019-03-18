Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AD30C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 06:23:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAC8A2077B
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 06:23:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAC8A2077B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2AC4F6B0003; Mon, 18 Mar 2019 02:23:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2329B6B0006; Mon, 18 Mar 2019 02:23:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FAEC6B0007; Mon, 18 Mar 2019 02:23:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id D3C556B0003
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 02:23:43 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id v123so7098873vkv.17
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 23:23:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=ZB9nJsDpKa1+tc/kynrz0Fmj61kcN4tZlEWpMXssfxY=;
        b=sfIPb4wisHQEy5F3bbbNExh+uiU65icbeya0s26/6Nm08WBVhxqH5Qc0N0Jksk+vTy
         w3tHTcms/apoQvVFhHNdIwXhJan6hwUqwpc660EXhoOwHYZPXjp1Fvja0G/6qMAXgkkz
         NZZxKDQJaZJiFCi1TVHzkFumU+JtokluuK4px2B6GyBDs7GEIXZw5+NSAeAkQDwuEg9X
         JLPjdGX4HhggTcKtdLST6REjZtgNF8D+hDx2MAORzFv7aiyvir9VB8m1BLScou2Wz7Tz
         TPjweh/NeuTiovIzjGM/dV1NuuidtYJ3QtcJ0NU5WwKfkFeUW2NJ0Q55/K0d+pLSbWyY
         N+kA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: APjAAAU+akx0+nz/taS0uvd5aE+fH9qzXzP1KilVKKQve3KSHXWY17H4
	OPVqY174ws5UaTtRA6FP/fX44OmPGDJzMzlb83MJPB6GsW3X4RqZ68MzXqkxs0KjL8USilStSm1
	UY/NXt0vxK89sryXnhrByYt1q52GXOoPILz4w6KcfoCyGS3xa8TFzoqOJlFD0lmoBHQ==
X-Received: by 2002:a67:eac9:: with SMTP id s9mr8502778vso.128.1552890223522;
        Sun, 17 Mar 2019 23:23:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxMWE6XIPzuhys0Xis5tVhYyROChmTJkXyWyz/zR1fyaWkD3PoG5FHYVLWRLLtm03YM+hMZ
X-Received: by 2002:a67:eac9:: with SMTP id s9mr8502761vso.128.1552890222539;
        Sun, 17 Mar 2019 23:23:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552890222; cv=none;
        d=google.com; s=arc-20160816;
        b=ALhgvcRBz1TotiYQPpc1AKY8JuQWLdU1IMrY7P6JEKEw9iZwHbVpicU/aOBtFtq+KV
         iWEDWpg3r5OMtVklZh1fouJ0s5gUp/SVcZHcDJPDd26pTLIeua5Zvr86qFoXvhvgINfN
         aiZUcZxN6e3r1kMJx/V63M6+ahuXIdGQQRBICdMKXxIHpj0JyY6A5zcIVp+yYbB+d8yy
         EzD38pGnlW3tEXBkTE0oQ1CDJSk6Z0maSghW7z/RsuY4z0pmaCchBp3sGBrSfACcyMcI
         OKeRnnsThhsunsQ1Hw9SCammTr6yKuE5TbVib+CkK1xVP9WC/gRUf9J7/t3nu/mIPS6P
         W23w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=ZB9nJsDpKa1+tc/kynrz0Fmj61kcN4tZlEWpMXssfxY=;
        b=Sy4+cDNq9dDXbwY4ZxTDZwtN9kQSLHU40ytRIuLQwoTjS5VqBGsRQN8kAZ3NdgwLdh
         OorXK93LBvo9vLWKShl6dRl9ypPVj7PiqdvhVAeI/mu1QVAqy8XOfBNPKuF8AGSxw+4b
         IvkxRFtKhBr315/e9jZoysxKNgsBz34MhhCe/m2oVpICQc0/U5IFXj6IwiFCJtwPpFm6
         xGAgK5piyFPJ1+DD2IwzQaApxr2EZ+j5F65u3tan/1Ps1FvhMR29fbDDbPW6rxGEiJU9
         gN5+AwE+QJLLBfgO8tMmWTsDGu/iMqBRHUIjP2EBwbiwQhSA4NtlP6ifSNtt1g13HERl
         Pm0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id r184si1824791vsc.92.2019.03.17.23.23.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Mar 2019 23:23:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS411-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id CD773565038434D6CCAB;
	Mon, 18 Mar 2019 14:23:36 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS411-HUB.china.huawei.com
 (10.3.19.211) with Microsoft SMTP Server id 14.3.408.0; Mon, 18 Mar 2019
 14:23:34 +0800
Message-ID: <5C8F3965.2050202@huawei.com>
Date: Mon, 18 Mar 2019 14:23:33 +0800
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
References: <CACT4Y+Z+CH0UTdSz-w_woMPrBwg-GuobV1Su4qd9ReffTkyfVg@mail.gmail.com> <5C7D2F82.40907@huawei.com> <CACT4Y+agwaszODNGJHCqn4fSk4Le9exn3Cau0nornJ0RaTpDJw@mail.gmail.com> <5C7D4500.3070607@huawei.com> <CACT4Y+b6y_3gTpR8LvNREHOV0TP7jB=Zp1L03dzpaz_SaeESng@mail.gmail.com> <5C7E1A38.2060906@huawei.com> <20190306020540.GA23850@redhat.com> <5C821550.50506@huawei.com> <20190315213944.GD9967@redhat.com> <5C8CC42E.1090208@huawei.com> <20190316194222.GA29767@redhat.com>
In-Reply-To: <20190316194222.GA29767@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/3/17 3:42, Andrea Arcangeli wrote:
> On Sat, Mar 16, 2019 at 05:38:54PM +0800, zhong jiang wrote:
>> On 2019/3/16 5:39, Andrea Arcangeli wrote:
>>> On Fri, Mar 08, 2019 at 03:10:08PM +0800, zhong jiang wrote:
>>>> I can reproduce the issue in arm64 qemu machine.  The issue will leave after applying the
>>>> patch.
>>>>
>>>> Tested-by: zhong jiang <zhongjiang@huawei.com>
>>> Thanks a lot for the quick testing!
>>>
>>>> Meanwhile,  I just has a little doubt whether it is necessary to use RCU to free the task struct or not.
>>>> I think that mm->owner alway be NULL after failing to create to process. Because we call mm_clear_owner.
>>> I wish it was enough, but the problem is that the other CPU may be in
>>> the middle of get_mem_cgroup_from_mm() while this runs, and it would
>>> dereference mm->owner while it is been freed without the call_rcu
>>> affter we clear mm->owner. What prevents this race is the
>> As you had said, It would dereference mm->owner after we clear mm->owner.
>>
>> But after we clear mm->owner,  mm->owner should be NULL.  Is it right?
>>
>> And mem_cgroup_from_task will check the parameter. 
>> you mean that it is possible after checking the parameter to  clear the owner .
>> and the NULL pointer will trigger. :-(
> Dereference mm->owner didn't mean reading the value of the mm->owner
> pointer, it really means to dereference the value of the pointer. It's
> like below:
>
> get_mem_cgroup_from_mm()		failing fork()
> ----					---
> task = mm->owner
> 					mm->owner = NULL;
> 					free(mm->owner)
> *task /* use after free */
>
> We didn't set mm->owner to NULL before, so the window for the race was
> larger, but setting mm->owner to NULL only hides the problem and it
> can still happen (albeit with a smaller window).
>
> If get_mem_cgroup_from_mm() can see at any time mm->owner not NULL,
> then the free of the task struct must be delayed until after
> rcu_read_unlock has returned in get_mem_cgroup_from_mm(). This is
> the standard RCU model, the freeing must be delayed until after the
> next quiescent point.

Thank you for your explaination patiently.  The patch should go to upstream too.  I think you
should send a formal patch to the mainline.  Maybe other people suffer from
the issue.  :-)

Thanks,
zhong jiang
> BTW, both mm_update_next_owner() and mm_clear_owner() should have used
> WRITE_ONCE when they write to mm->owner, I can update that too but
> it's just to not to make assumptions that gcc does the right thing
> (and we still rely on gcc to do the right thing in other places) so
> that is just an orthogonal cleanup.
>
> Thanks,
> Andrea
>
> .
>


