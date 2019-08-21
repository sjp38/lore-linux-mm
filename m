Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10328C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 16:00:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8A742339F
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 16:00:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PfRGf7dJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8A742339F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B9E46B0301; Wed, 21 Aug 2019 12:00:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 469F16B0302; Wed, 21 Aug 2019 12:00:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 380B66B0303; Wed, 21 Aug 2019 12:00:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0031.hostedemail.com [216.40.44.31])
	by kanga.kvack.org (Postfix) with ESMTP id 195BA6B0301
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 12:00:42 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id BA1BD8248AAA
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 16:00:41 +0000 (UTC)
X-FDA: 75846897882.15.land68_23172ac2ee357
X-HE-Tag: land68_23172ac2ee357
X-Filterd-Recvd-Size: 4435
Received: from mail-qk1-f196.google.com (mail-qk1-f196.google.com [209.85.222.196])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 16:00:41 +0000 (UTC)
Received: by mail-qk1-f196.google.com with SMTP id 125so2274041qkl.6
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 09:00:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=SkQ1iRQmedFusEhYknXF0m0szFVCfve43ayyHL3P7UE=;
        b=PfRGf7dJmGlq/vFV6Y+jNfBdQj9FXFXpgr4U2sqHZkOOzikZqcKARWfm/Ay9cjoDSU
         SCX+h5EJLGStrV2y6/OzsiFWSydoRDIB8xs/LthT66NJMLZAYtyRP5nrnZgOEeHiNyJk
         1bf35F88LlY3ZL6xZzCIEGGOZVVSZr2saC2AonVkeLUBSZKclxcjROkdE6IhiIiZK18A
         z1eW4eMKnZKE5uALGEnUQyOrqFkSKIT6AjOY4D73Eu6oZ+ZkI6UO+7WVtIvPOc7iPQV5
         aAxUr8psXAumVPPm2Vln5wKADn3tcXCg2XrJ+MksLKbdQw0SqjF2hpb4xY0Ud7EO5OH2
         B8bg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=SkQ1iRQmedFusEhYknXF0m0szFVCfve43ayyHL3P7UE=;
        b=RnDkoDpByKq6rX+ZPerTBpP1HLwiKFNGwu+4VbVDiC2LtPB7LUEG5W/+PApH9MECxP
         ZhjwdRbLJ3NDVkCHKOlBeNizQTpghWjmBrvdegsEX5WFaV03P6LmcN6Ix8igxBqVdJxm
         H/dBx9rW84RWD7tg4DeEQeENF3DTiLBH8j7YPXvUULHn8Ty0jt1rVWFeAsxNJc+zUcZD
         Rkqr798A8upr4Nd6MEg7peiDctFAB/94K+gvbpcdg/QzP+9hrXBr8V2gyx5ckqMkG8qp
         Fjmp26hr5RanHLOBlioGOZxXgScOEbt+l/J/EVNE70it5yq9PknIezIZRFn0GFYAXktC
         GdBA==
X-Gm-Message-State: APjAAAWqZFvYKIbtcgTNpDyxqPPqKQ8v6Zzkc0bWl35saSFR6YBnwa/O
	Adoy8sIacp3BAB10MAvN0DA=
X-Google-Smtp-Source: APXvYqygD4G25/4+1lbrU9OJUBtreiUUAzC3687HWTZ5HRPAeIzC0XOf19SJJBxuWv+Hi3cQWG/YHA==
X-Received: by 2002:a37:395:: with SMTP id 143mr32776745qkd.317.1566403240448;
        Wed, 21 Aug 2019 09:00:40 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:1f05])
        by smtp.gmail.com with ESMTPSA id s58sm11388981qth.59.2019.08.21.09.00.38
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Aug 2019 09:00:39 -0700 (PDT)
Date: Wed, 21 Aug 2019 09:00:37 -0700
From: Tejun Heo <tj@kernel.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, hannes@cmpxchg.org, mhocko@kernel.org,
	vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, guro@fb.com, akpm@linux-foundation.org
Subject: Re: [PATCH 5/5] writeback, memcg: Implement foreign dirty flushing
Message-ID: <20190821160037.GK2263813@devbig004.ftw2.facebook.com>
References: <20190815195619.GA2263813@devbig004.ftw2.facebook.com>
 <20190815195930.GF2263813@devbig004.ftw2.facebook.com>
 <20190816160256.GI3041@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190816160256.GI3041@quack2.suse.cz>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On Fri, Aug 16, 2019 at 06:02:56PM +0200, Jan Kara wrote:
> 1) You ask to writeback LONG_MAX pages. That means that you give up any
> livelock avoidance for the flusher work and you can writeback almost
> forever if someone is busily dirtying pages in the wb. I think you need to
> pick something like amount of dirty pages in the given wb (that would have
> to be fetched after everything is looked up) or just some arbitrary
> reasonably small constant like 1024 (but then I guess there's no guarantee
> stuck memcg will make any progress and you've invalidated the frn entry
> here).

I see.  Yeah, I think the right thing to do would be feeding the
number of dirty pages or limiting it to one full sweep.  I'll look
into it.

> 2) When you invalidate frn entry here by writing 0 to 'at', it's likely to get
> reused soon. Possibly while the writeback is still running. And then you
> won't start any writeback for the new entry because of the
> atomic_read(&frn->done.cnt) == 1 check. This seems like it could happen
> pretty frequently?

Hmm... yeah, the clearing might not make sense.  I'll remove that.

Thanks.

-- 
tejun

