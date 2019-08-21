Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D98FFC3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 16:04:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 992CE233A0
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 16:04:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FcPaI0pB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 992CE233A0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 182BD6B0305; Wed, 21 Aug 2019 12:04:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10C886B0306; Wed, 21 Aug 2019 12:04:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F15806B0307; Wed, 21 Aug 2019 12:04:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0052.hostedemail.com [216.40.44.52])
	by kanga.kvack.org (Postfix) with ESMTP id C9A016B0305
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 12:04:34 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 74F41A2D9
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 16:04:34 +0000 (UTC)
X-FDA: 75846907668.17.jar78_44f609202423a
X-HE-Tag: jar78_44f609202423a
X-Filterd-Recvd-Size: 3960
Received: from mail-qt1-f193.google.com (mail-qt1-f193.google.com [209.85.160.193])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 16:04:33 +0000 (UTC)
Received: by mail-qt1-f193.google.com with SMTP id x4so3657734qts.5
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 09:04:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=pSYvDILhSH8fJWFn1Ay93bkSas+NlIGIDDL+tHz2nnY=;
        b=FcPaI0pBK/tsTJ85fkJV0GzNaa0VI6xq2/3C77dJ9Ksg2LPi+NeYin58kEZaHWQ4+c
         yNts5ywVYjfMNCER2xvTfME0oKqC0YC2I4+K1tsuNpQiaJjKZTyj3LDo3/o+40aLy1b3
         xFROy6h268Qz/2709NunEce2lWelxf9pFlX7BM8kPI3y5yOWd5UyF8HaxBcv8mpUorwb
         8wJ1/du7AiJGYKqbpfRUjO9rT+TCM/8hnViWhPuAotTO6NOkCjN1Clp8ecE6hIl6tYqF
         MHer6bExHhfCK5pjD900mPPO3BKg9ILIPrD3FA13M/iRdL1oZqc+Ge1OIPSGrhdITT6H
         MvGA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=pSYvDILhSH8fJWFn1Ay93bkSas+NlIGIDDL+tHz2nnY=;
        b=c1XD/txhqqX7TEvHo0hqyHuryYST/Jo8gF1ca4efDQG0lMKRMsxVTbo7K9DBVVvkaH
         LQ/e1YJnERjeMAzG1wjtNguXULuiFzbOSAU0FUR24IJez7KhSEBog2a2taxf1h9bH/fB
         J0ODuBpzgQMkJdcPeqfT3+pJx6Jmo7NQnDOlQXBRtT88KBWZL2KU++BgathAm22AUuMV
         FCILz2GHtXaqxyjGPqUzn8uAK0uIYLQZgIL+SQYsnt488n9tMks4gYGX3rca3uTToZZP
         eJ7KrrbQQDUZ4TgXWuk5W6WNXbLA0BGJsQSUySbDxYspxXoeSxA770lLeydIimcvhwry
         0plQ==
X-Gm-Message-State: APjAAAXyIVvid8FK+ShnuCT686gXz9C7gx72HY6ueGKRDLOhxMVml9EX
	rTDdJ+2RXeTJTRvahDGEr0g=
X-Google-Smtp-Source: APXvYqxpFrzdsIp5vYz/r7TIVsm3AF8l2qHkWaxK1IbWJsfJxsILknQZQre8GqBdTdcjbqhL1sL5hQ==
X-Received: by 2002:a0c:edcb:: with SMTP id i11mr18388359qvr.206.1566403473118;
        Wed, 21 Aug 2019 09:04:33 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:1f05])
        by smtp.gmail.com with ESMTPSA id v126sm10464175qkh.3.2019.08.21.09.04.32
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Aug 2019 09:04:32 -0700 (PDT)
Date: Wed, 21 Aug 2019 09:04:30 -0700
From: Tejun Heo <tj@kernel.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, hannes@cmpxchg.org, mhocko@kernel.org,
	vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, guro@fb.com, akpm@linux-foundation.org
Subject: Re: [PATCH 5/5] writeback, memcg: Implement foreign dirty flushing
Message-ID: <20190821160430.GL2263813@devbig004.ftw2.facebook.com>
References: <20190815195619.GA2263813@devbig004.ftw2.facebook.com>
 <20190815195930.GF2263813@devbig004.ftw2.facebook.com>
 <20190816160256.GI3041@quack2.suse.cz>
 <20190821160037.GK2263813@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190821160037.GK2263813@devbig004.ftw2.facebook.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000044, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 21, 2019 at 09:00:37AM -0700, Tejun Heo wrote:
> > 2) When you invalidate frn entry here by writing 0 to 'at', it's likely to get
> > reused soon. Possibly while the writeback is still running. And then you
> > won't start any writeback for the new entry because of the
> > atomic_read(&frn->done.cnt) == 1 check. This seems like it could happen
> > pretty frequently?
> 
> Hmm... yeah, the clearing might not make sense.  I'll remove that.

Oh, the reuse logic checks whether done.cnt == 1 and only reuse if no
writeback is still in flight, so this one should be fine.

Thanks.

-- 
tejun

