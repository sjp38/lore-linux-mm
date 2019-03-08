Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 569C5C10F09
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 17:22:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC1EC20851
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 17:22:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=toxicpanda-com.20150623.gappssmtp.com header.i=@toxicpanda-com.20150623.gappssmtp.com header.b="BupmmeZk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC1EC20851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=toxicpanda.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FD1E8E0003; Fri,  8 Mar 2019 12:22:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3AE7B8E0002; Fri,  8 Mar 2019 12:22:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C4C58E0003; Fri,  8 Mar 2019 12:22:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id F2A398E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 12:22:23 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id s65so16505594qke.16
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 09:22:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=JbH57hj38dbuvh9sgqbNRJMeCQlSikG1kcp1+esyKsE=;
        b=AufS0fO14gRfAUiG8JkY/W7Z8w6ztg/shGc5Spm5tjrBoQBNuH01Zgv8bsneLFUB4Y
         ETYLBzlxXc+3hHWry6+OlH/0y3DxTlB5NAL1CbLOPr02vU6s6qbgBzYziZkGi5G9/6VC
         pv1t7uRbPLTcHIWqw5EQ9/zgyu52hsa6U4tmW6vdc3Tal3qWwboXLZTemoIfnw0gbLq7
         ON/I12Vz363n4Hoqg1Ymj/na2SHIm7cuO5BMo9g9rtOZGoeaIptJdfKmlOWeZNLRVjUF
         iTQ/T/5pjsDPbaVcMm9E+yu4B5rRpaZo8eTaS81dQVJ/9aw1TfoS1zxsTT4NI8NgFKcM
         LZUQ==
X-Gm-Message-State: APjAAAUwR+sZ7ZMyWFiqDbpYF3IbcEPEIscqPEYkmhSdOAr3FF3QsEsk
	Uowgbj/CpTbgSCWMrhNekePlvnwAedQHwoIDWEEtKLqfTKnEbuEbvlHbExPjtmNSBDRABffDuzq
	Qx6phqbxhlgDnV6i6WYNOQZfNUo3nYntEN+Y0Drzg+E4uQZQt/xumxyyFfcxmr+VVm+pGD75mED
	VycnLeXU2CGzl4FnJ1j+QBqY5Nb9i3UZLWlbbvL7d41B4jEAeaJ14YZ5Qp5dFJvGTwRWjrAh81d
	PeKSzr6PueTkSPBwBbGemMDnOtY+npAjrqihk/fjbsNdtXPhigWdMZo1+rHbXcR6URsW0fhIQMz
	p0OqE+aTCMSBDoyjB13KPSF9KBdx5MKMYMB1eaozGaP+hcouw3BBeekOcY6bZZd03HlRLZnDaWV
	x
X-Received: by 2002:ac8:365a:: with SMTP id n26mr15331806qtb.18.1552065743682;
        Fri, 08 Mar 2019 09:22:23 -0800 (PST)
X-Received: by 2002:ac8:365a:: with SMTP id n26mr15331749qtb.18.1552065742699;
        Fri, 08 Mar 2019 09:22:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552065742; cv=none;
        d=google.com; s=arc-20160816;
        b=BW70R/MzjT8nP3Xbr0GKRWwtFk4BAX3sY/6/4xJeKIbgGOGxyKh+NCK+MiQRfJ7vlz
         /ltYbzVdCt/nTXKwIawzab4Q6U58MN3E+cl4TvC6tXKlb4PROP/sBN76IinOa4U/rmDl
         iZkawYwHWM3XLnAP57m+05qFOrUpdm6fY2G2ik3V11i1Jxa9451JNlLRI5zxf3WNADd/
         q1807OT1XYD5yYqOYWfjunDOSzSKQc8dBrfsM+WisOVGZKCUPUBBKFyiWhFXgwSxYEKF
         K7SyTXpUzxjqjAlq3E4V1qete9lNHOkgMhC0oMJD18hMQNF/5OmyZUptiqBkXgTjr9LO
         1BOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=JbH57hj38dbuvh9sgqbNRJMeCQlSikG1kcp1+esyKsE=;
        b=kXVF0Zv3iOIF98OHLMHxI2AmHXpePKpgPRnG31JSdoLndOJ3S6uB9KOvlzeeJ54L69
         z5/cmFl500dxw8/yQ5DVgkYHJL0D6IN4l6Mt1Jd+lvw2cDRF0XbY4oumNlG/+KnARE18
         kLREiBgEtjXkQwn/IGqX4M7UXjyFWygylXJxiZhmaWEM8oqLU12iATj+Hmy3zxxA+se5
         eEVKZ8rArnzd1pA55uTuvH39G6YLv1EK5AC3avPONqaHIdnOPl1bCd3EsFDUsVwyeeyH
         RWiAm7Z+d7qvfmr8NOpAXhdqN2NIQX/2b9H7snyPoJhHntwZkGwNvL5G3A3cOQ1mwhBo
         keEA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@toxicpanda-com.20150623.gappssmtp.com header.s=20150623 header.b=BupmmeZk;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) smtp.mailfrom=josef@toxicpanda.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k17sor9355458qvm.12.2019.03.08.09.22.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Mar 2019 09:22:22 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@toxicpanda-com.20150623.gappssmtp.com header.s=20150623 header.b=BupmmeZk;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) smtp.mailfrom=josef@toxicpanda.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=toxicpanda-com.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=JbH57hj38dbuvh9sgqbNRJMeCQlSikG1kcp1+esyKsE=;
        b=BupmmeZkBGvKHTBw9Ba0knKotbsh2ucjHI0nGoWNbNfY/Vz5l98p4lh36/ATOGGIy/
         9kATlqWal45/OVi5k69K+pOW61YgOyiLvZ6r0VrpTgcM+sOfWv88hoQebSU3FIik95m/
         nqd7OdcTF0ygteH8C37NMIK2loiV2y+1untflcF5ccuY+lM7Ifx55dznXKhzRlE6DpzN
         0oexkJ8SnQGCq+yKpGzbO4uUslVcAW+V7oupFlO+Lnf8/ZjjXcXnppBSPK4iRRUext12
         wqA3iL83EOzC7Qf31kwEaU5WWO5d7OKXziWjufIToX8G26BQJNNAxiq2D1WEyceZLyho
         bvsg==
X-Google-Smtp-Source: APXvYqxFeMvdRVtcxpV/iBEVratRFw6cxDJJ6VFy3yGqZG2kucewCRZA1txSERTsvGbbrU+ybjftdQ==
X-Received: by 2002:a0c:b785:: with SMTP id l5mr15957092qve.225.1552065742151;
        Fri, 08 Mar 2019 09:22:22 -0800 (PST)
Received: from localhost ([107.15.81.208])
        by smtp.gmail.com with ESMTPSA id n27sm2064404qtf.11.2019.03.08.09.22.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 09:22:21 -0800 (PST)
Date: Fri, 8 Mar 2019 12:22:20 -0500
From: Josef Bacik <josef@toxicpanda.com>
To: Andrea Righi <andrea.righi@canonical.com>
Cc: Josef Bacik <josef@toxicpanda.com>, Tejun Heo <tj@kernel.org>,
	Li Zefan <lizefan@huawei.com>,
	Paolo Valente <paolo.valente@linaro.org>,
	Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>,
	Vivek Goyal <vgoyal@redhat.com>, Dennis Zhou <dennis@kernel.org>,
	cgroups@vger.kernel.org, linux-block@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 0/3] blkcg: sync() isolation
Message-ID: <20190308172219.clcu6ehjav6y2hxi@MacBook-Pro-91.local>
References: <20190307180834.22008-1-andrea.righi@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190307180834.22008-1-andrea.righi@canonical.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000041, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 07:08:31PM +0100, Andrea Righi wrote:
> = Problem =
> 
> When sync() is executed from a high-priority cgroup, the process is forced to
> wait the completion of the entire outstanding writeback I/O, even the I/O that
> was originally generated by low-priority cgroups potentially.
> 
> This may cause massive latencies to random processes (even those running in the
> root cgroup) that shouldn't be I/O-throttled at all, similarly to a classic
> priority inversion problem.
> 
> This topic has been previously discussed here:
> https://patchwork.kernel.org/patch/10804489/
> 

Sorry to move the goal posts on you again Andrea, but Tejun and I talked about
this some more offline.

We don't want cgroup to become the arbiter of correctness/behavior here.  We
just want it to be isolating things.

For you that means you can drop the per-cgroup flag stuff, and only do the
priority boosting for multiple sync(2) waiters.  That is a real priority
inversion that needs to be fixed.  io.latency and io.max are capable of noticing
that a low priority group is going above their configured limits and putting
pressure elsewhere accordingly.

Tejun said he'd rather see the sync(2) isolation be done at the namespace level.
That way if you have fs namespacing you are already isolated to your namespace.
If you feel like tackling that then hooray, but that's a separate dragon to slay
so don't feel like you have to right now.

This way we keep cgroup doing its job, controlling resources.  Then we allow
namespacing to do its thing, isolating resources.  Thanks,

Josef

