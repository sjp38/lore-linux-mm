Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48D47C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 18:29:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6FFB206DD
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 18:29:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6FFB206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6455C8E0003; Wed,  6 Mar 2019 13:29:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CE228E0002; Wed,  6 Mar 2019 13:29:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46EDA8E0003; Wed,  6 Mar 2019 13:29:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 17FC88E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 13:29:51 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id u13so10683060qkj.13
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 10:29:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4iLZxLjI5Cln+MCbO6Bs6/KoKG0M4uvB506OkZk0lHg=;
        b=JeXRcY25W5QpaXLtHlKPUM7k+OrM/xdzT62F2y/yB23PlziRx+VDcZ9DOpKv2ELl2L
         4kDYpxMdQK9+eLGfAyaNnm8glBq1cOT4E78lSj4MmpRkeMYE5o/PbI5Rsvs4XjtxxDEn
         seE4J6LTahV67qVvCHxsoNHebvepiJ5Gczyuf7TxBrcXYH9WxPW9cgwHJs+DmeJ7tVdn
         kLu+31ePnlXRIgOsx9TWle4m1Fz6xTdAV2mJf45ZUAsqazxE5YVJYkh/9XqsKYrRxgYc
         Gw8mIO75NowaPoB7k9Gv/oUW+fE6jhz1HX2XaHl94Y4Uu15ueNGQSkVUYAYaiV1e9VMb
         8Ncg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW07noUynizbhFbR8QlDq0+2+89gCN0GN5h4VuKOf9du55vq5Sh
	0q7kge5kr7aqH7aZ6B8MFWKpeSLvQq+JeBpGWPj4squxTztkJayQq3G7QuH23IURkjdCq6vSjh9
	STLVgNnnHMOM1ir9hAcuZt8Jpbm1hLNC6CKUzee3l+LtB446TtVi23rKIUPHFpX83zg==
X-Received: by 2002:a37:d409:: with SMTP id l9mr7043959qki.211.1551896990844;
        Wed, 06 Mar 2019 10:29:50 -0800 (PST)
X-Google-Smtp-Source: APXvYqxm8XurmVgee5Gz2qvqaQ3Oa0v93hZ1c939wS3hdNG79GfazTmsqBbhKNuPH57GUritmeCp
X-Received: by 2002:a37:d409:: with SMTP id l9mr7043895qki.211.1551896989742;
        Wed, 06 Mar 2019 10:29:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551896989; cv=none;
        d=google.com; s=arc-20160816;
        b=r6jje8MacqCE5SreXWccg2kPCvD6rvKQn+gZhTTRxp0fbXkhQWpsn6hmd+6sap5BmG
         +87OXVL29TGDvHmASEGvOCWmPC6qbAGPlOYytNTxsYVeEDjhQSLkQhDwksQYQQ2H40Ux
         KCtOnCN4Bu7c33CTt2YR8Cycq84ZLDy2wqVSQS2jx1xbflMROVuxqdChPGzXtpqkV5hJ
         t4RZDNlNhABKxdX6Ng4jxHaB+EfW36Js+HrQfMizi2Tg0hQhrsHkogrqWycGm8K46rCM
         tAd5L+TAiYDJYGLKqGO1LsUxN6jxJ7WPSOF7qRhf4MmQAg45M95f+azmspqTBZOPUv/R
         K53A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4iLZxLjI5Cln+MCbO6Bs6/KoKG0M4uvB506OkZk0lHg=;
        b=N2He95mdfRkwWUcxVJkCsLnJXiDMiC8Jk1lDTl3cII5zVMN5IzAKegX4RICCPi7FQz
         vUYcOmOiShzNkvme9iCGIF18gmeKWbXHdQL+sswBCIr0P5oQaVOVSjln3uMTRjeXkNEy
         CSP1dTD5hXpIiWqQw8QaQWoMbrv2taU9buXQihV0c4rCR0VwrAleaPudpYl7p9NyJ47Z
         Lh4OiT1n+1OcN4DiU1JXNWKpTF/RMwgBlm71VKzQEo4e5EbP/w1j3RjdV7QwiX3P8zpj
         uv+SXLbqRTyKhxgzjCzDzCIX1gfbCgV7nZm5rJYb2r13eys2tYJqrR0VhtkJZC0xSpAZ
         H59Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p21si876744qke.214.2019.03.06.10.29.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 10:29:49 -0800 (PST)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 71705E6A6D;
	Wed,  6 Mar 2019 18:29:48 +0000 (UTC)
Received: from sky.random (ovpn-121-1.rdu2.redhat.com [10.10.121.1])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id DBAEB1001DC5;
	Wed,  6 Mar 2019 18:29:45 +0000 (UTC)
Date: Wed, 6 Mar 2019 13:29:44 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Peter Xu <peterx@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	syzbot <syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com>,
	Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org,
	Johannes Weiner <hannes@cmpxchg.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	David Rientjes <rientjes@google.com>,
	Hugh Dickins <hughd@google.com>,
	Matthew Wilcox <willy@infradead.org>, Mel Gorman <mgorman@suse.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: KASAN: use-after-free Read in get_mem_cgroup_from_mm
Message-ID: <20190306182944.GE23850@redhat.com>
References: <CACT4Y+agwaszODNGJHCqn4fSk4Le9exn3Cau0nornJ0RaTpDJw@mail.gmail.com>
 <5C7D4500.3070607@huawei.com>
 <CACT4Y+b6y_3gTpR8LvNREHOV0TP7jB=Zp1L03dzpaz_SaeESng@mail.gmail.com>
 <5C7E1A38.2060906@huawei.com>
 <20190306020540.GA23850@redhat.com>
 <5C7F6048.2050802@huawei.com>
 <20190306062625.GA3549@rapoport-lnx>
 <5C7F7992.7050806@huawei.com>
 <20190306081201.GC11093@xz-x1>
 <5C7FC5F4.40903@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5C7FC5F4.40903@huawei.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Wed, 06 Mar 2019 18:29:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Zhong,

On Wed, Mar 06, 2019 at 09:07:00PM +0800, zhong jiang wrote:
> The patch use call_rcu to delay free the task_struct, but It is possible to free the task_struct
> ahead of get_mem_cgroup_from_mm. is it right?

Yes it is possible to free before get_mem_cgroup_from_mm, but if it's
freed before get_mem_cgroup_from_mm rcu_read_lock,
rcu_dereference(mm->owner) will return NULL in such case and there
will be no problem.

The simple fix also clears the mm->owner of the failed-fork-mm before
doing the call_rcu. The call_rcu delays the freeing after no other CPU
runs in between rcu_read_lock/unlock anymore. That guarantees that
those critical section will see mm->owner == NULL if the freeing of
the task strut already happened.

The solution Mike suggested for this and that we were wondering as
ideal in the past for the signal issue too, is to move the uffd
delivery at a point where fork is guaranteed to succeed. We should
probably try that too to see how it looks like and if it can be done
in a not intrusive way, but the simple fix that uses RCU should work
too.

Rolling back in case of errors inside fork itself isn't easily doable:
the moment we push the uffd ctx to the other side of the uffd pipe
there's no coming back as that information can reach the userland of
the uffd monitor/reader thread immediately after. The rolling back is
really the other thread failing at mmget_not_zero eventually. It's the
userland that has to rollback in such case when it gets a -ESRCH
retval.

Note that this fork feature is only ever needed in the non-cooperative
case, these things never need to happen when userfaultfd is used by an
app (or a lib) that is aware that it is using userfaultfd.

Thanks,
Andrea

