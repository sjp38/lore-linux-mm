Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 384AAC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 19:14:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7FBB213F2
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 19:14:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="lGKqWcLG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7FBB213F2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 610886B0006; Tue, 19 Mar 2019 15:14:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BFAD6B0007; Tue, 19 Mar 2019 15:14:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AEFD6B0008; Tue, 19 Mar 2019 15:14:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 23ED96B0006
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 15:14:55 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id y64so10896845qka.3
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 12:14:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=eJlA5b/2FGId2EKihm7V3BwbEtF4wJiWzxoeFUYWeqo=;
        b=nD/jNm8edBmFL8FXUrup0RVo7CJ2d6LTyAk1EG4dJ4gyEDv3LlZa4XgNvZSWF7fvxc
         NItHgoeIIDGD8kEehST/iq04lgTV8BDIg2UAbwgH5ZlBJRc7htzkdpwSLA/zlEYbHmOE
         g+yUAxC00gmQbJmj4wOLv4NsFu7C3TqhAZX95iq2eS+bk9v0L5BlvOrROVsDfvCcGA3P
         XH1uEyJfTv45YgwGikyOiAFBrvKIqrveQnP3D3KE/lz3EQq5VZjC5q7PYKwrEmqHBST3
         z5RRSFrtqmdjNumlkeGWs7hZO1iDeqvigQG39MwmC43LakFyNzWNgWxGayVFsaa8ar7C
         8Cpg==
X-Gm-Message-State: APjAAAU4uqceriMVaFVXr9mbfcIu5/6GZ3vdY/6328NEY4mZipLvogzt
	j4J0NT3+HI13t8eGbDodEh7KcnTJkA2AeiGekR8kYsmuQzcodZ/sKUCJTq8UDiuAswJYnQMyL0m
	mSIsXZxXF228lyN6lz+2q12GE0lOyaJm4ajiVE6/lxOHOijseJehOtI/L2tkaT4Ocyg==
X-Received: by 2002:a37:47cb:: with SMTP id u194mr3157860qka.296.1553022894918;
        Tue, 19 Mar 2019 12:14:54 -0700 (PDT)
X-Received: by 2002:a37:47cb:: with SMTP id u194mr3157806qka.296.1553022894043;
        Tue, 19 Mar 2019 12:14:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553022894; cv=none;
        d=google.com; s=arc-20160816;
        b=RAv4niI+pdLXVSN7mSEnP54Er3N2eQIPxUDITfV8Jx5LKnGW/XI/RCij+efhyYN2b/
         NsctZCZTZTFnmvMMSyB96ZkHSrcGuFAratybje6x0YitDG0aAlEFU2mWInrUP7tKcXuW
         5/Y+PhN+qngVIBrS4J0jELAyKs1atPQvzFtYXn3snR4dpUE6z+sPHbRQA0cQKhP/lhMp
         JUeNNvRFnWg1IUCdH8uDyIWiHY3bHgQmRGcYxnBL0m+si1YhyluioKj1IL8YvgD/yMfL
         7fTThKFltRQ7QUo4zawfcv3pGVXFQ06AyfW0mPqQjLCoWe2xaXl9bMqXkIuN25S/mAL5
         PZcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=eJlA5b/2FGId2EKihm7V3BwbEtF4wJiWzxoeFUYWeqo=;
        b=iY4evkbau73vPnly/KGhRJFLYngrTfbDdpMM3N8bRt6lUjOcOwSnfm2tNlI2s2O/1q
         AXEWBMvc+NdoSwz1/Sm8+MbWV87ujwWTJyN6FYYpaWZ4tIzmVI7xGUwoXapLXTkHpw1n
         VMxwIARE3KdS0B34i7xOFVF+JWv3T5yGP/EGhYTGBf014hKjEUWm3Z6z2A6gFBpNsm5h
         IFJOrUlKn1wffYZxYy/7RTdD0Tq+yBKlkIslWaKBB26RcJB52wzAuEZ3Gg7bgj3K6vaP
         htG7WJ9KzTN11VFmy+yFtsJWWGPgUcglpAIkgBEvOWODuJZVAz+KZc7pwxglyCwaW1Gd
         3Zvw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=lGKqWcLG;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i21sor7538420qkg.146.2019.03.19.12.14.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 12:14:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=lGKqWcLG;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=eJlA5b/2FGId2EKihm7V3BwbEtF4wJiWzxoeFUYWeqo=;
        b=lGKqWcLGRtp3qWcnzReq25nzeoNdSEmapSwYOBALcym3L+zl4EYeSe8YMrWcs4/PlS
         c303CI00oi13rKLIH2Hj+igOhXyvveKDeoO7aA4UIiaDbtFdFtPODi1XGt4LcB2Pocg/
         g6CDsxmoeQAIB2V49nrOXFqtbZk/pN8Nh34aSscPthMdPjvityOc3Sd6zhpUl/3/V1Ta
         abF/099QqfJifuyzgyxP0rEVwrJYM7K/seF9lIl7JvF8kI24YUU9mGO7BEIOI5pkjcf8
         0O+55CTptGEVwe0TWatr/i2VB3WIkAKJakO7AFfhb3n7bPtlml9qCBl4evPwR1Bf2akl
         3Ugw==
X-Google-Smtp-Source: APXvYqzguXsFfyYxgrWZahIw5uDi6s5sQkU4StEbwPpFZK2MITAf35CmaCqnvh7dn181oz6UMunRDg==
X-Received: by 2002:a37:bbc3:: with SMTP id l186mr3060376qkf.239.1553022893629;
        Tue, 19 Mar 2019 12:14:53 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id t35sm5513775qtc.10.2019.03.19.12.14.52
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 12:14:53 -0700 (PDT)
Message-ID: <1553022891.26196.7.camel@lca.pw>
Subject: Re: kernel BUG at include/linux/mm.h:1020!
From: Qian Cai <cai@lca.pw>
To: Mel Gorman <mgorman@techsingularity.net>, Daniel Jordan
	 <daniel.m.jordan@oracle.com>
Cc: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>, linux-mm@kvack.org, 
	vbabka@suse.cz
Date: Tue, 19 Mar 2019 15:14:51 -0400
In-Reply-To: <20190317152204.GD3189@techsingularity.net>
References: 
	<CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
	 <20190315205826.fgbelqkyuuayevun@ca-dmjordan1.us.oracle.com>
	 <20190317152204.GD3189@techsingularity.net>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 2019-03-17 at 15:22 +0000, Mel Gorman wrote:
> On Fri, Mar 15, 2019 at 04:58:27PM -0400, Daniel Jordan wrote:
> > On Tue, Mar 12, 2019 at 10:55:27PM +0500, Mikhail Gavrilov wrote:
> > > Hi folks.
> > > I am observed kernel panic after updated to git commit 610cd4eadec4.
> > > I am did not make git bisect because this crashes occurs spontaneously
> > > and I not have exactly instruction how reproduce it.
> > > 
> > > Hope backtrace below could help understand how fix it:
> > > 
> > > page:ffffef46607ce000 is uninitialized and poisoned
> > > raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
> > > raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
> > > page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
> > > ------------[ cut here ]------------
> > > kernel BUG at include/linux/mm.h:1020!
> > > invalid opcode: 0000 [#1] SMP NOPTI
> > > CPU: 1 PID: 118 Comm: kswapd0 Tainted: G         C
> > > 5.1.0-0.rc0.git4.1.fc31.x86_64 #1
> > > Hardware name: System manufacturer System Product Name/ROG STRIX
> > > X470-I GAMING, BIOS 1201 12/07/2018
> > > RIP: 0010:__reset_isolation_pfn+0x244/0x2b0
> > 
> > This is new code, from e332f741a8dd1 ("mm, compaction: be selective about
> > what
> > pageblocks to clear skip hints"), so I added some folks.
> > 
> 
> I'm travelling at the moment and only online intermittently but I think
> it's worth noting that the check being tripped is during a call to
> page_zone() that also happened before the patch was merged too. I don't
> think it's a new check as such. I haven't been able to isolate a source
> of corruption in the series yet and suspected in at least one case that
> there is another source of corruption that is causing unrelated
> subsystems to trip over.
> 

So reverting this patch on the top of the mainline fixed the memory corruption
for me or at least make it way much harder to reproduce.

dbe2d4e4f12e ("mm, compaction: round-robin the order while searching the free
lists for a target")

This is easy to reproduce on both KVM and bare-metal using the reproducer.

# swapoff -a
# i=0; while :; do i=$((i+1)); echo $i | tee /tmp/log ;
/opt/ltp/testcases/bin/oom01; sleep 5; done

The memory corruption always happen within 300 tries. With the above patch
reverted, both the mainline and linux-next survives with 1k+ attempts so far.

