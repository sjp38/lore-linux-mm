Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 135A6C3A59C
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 16:12:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4C47206C1
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 16:12:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QXjkEAHz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4C47206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FF3B6B02B9; Thu, 15 Aug 2019 12:12:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AFB76B02BA; Thu, 15 Aug 2019 12:12:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C61D6B02BB; Thu, 15 Aug 2019 12:12:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0106.hostedemail.com [216.40.44.106])
	by kanga.kvack.org (Postfix) with ESMTP id EEAE86B02B9
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 12:12:15 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 983E9180AD801
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:12:15 +0000 (UTC)
X-FDA: 75825154230.29.river14_4de22be0c2e4d
X-HE-Tag: river14_4de22be0c2e4d
X-Filterd-Recvd-Size: 4074
Received: from mail-qt1-f194.google.com (mail-qt1-f194.google.com [209.85.160.194])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:12:15 +0000 (UTC)
Received: by mail-qt1-f194.google.com with SMTP id j15so2834053qtl.13
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 09:12:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=iTIKIuhQjFmLzffUqNs0d7EM6m2UJCFz471NWYlW/kA=;
        b=QXjkEAHzvaI4d+a1jTu1uuBdBcwkiUcidF6xSV/xQKF2N7ucXBCF5Hej38FIPF0Lm3
         9fWE+N6hf68OLIhzBONo5J5LQOEGzbqPKECQp+aEdwFdT+opMpMJ1qGxqzQD9gdQCPEz
         IecizOukDzYwhTyD2KWejogmiAgKaK1vXPLIaF4L9biBH+TFPKprcr2WQ/6fGoTrK2rx
         p6Un0uytpeqSTUTd8k+dvepjTTMJOAFXt4wObsUiZTFbAJFHR3q+4a3Y/b8ZvK/foXDm
         wpA60ZcOdP6GWCrYCNX13gHb4P/T2mGkfQelkmBGCL+lGa6+8NnbqBd7hYAfkgZPkPEV
         CS9w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=iTIKIuhQjFmLzffUqNs0d7EM6m2UJCFz471NWYlW/kA=;
        b=TDBudotPR8YVR3j1ufrpvyUxTMSsr8YUMaNTv5HevWSvUCzGysPI4kqEs0hTctk1CO
         pFgjCXknNhFY/elPwlq7WvxkcxXhF3Yo9JJhGkcFpMgytalB+U3l+B80gKAFIsHdar3Z
         RByP8vSLab86tUxbAzu7VSMzhG8wtvUOZk1p7nm/D+/aHZswhzksPcM29Fs7Y/4/hTZa
         cp9MIWiZJk/NW6zmIXMgGHY4Jd/+4c29l1bEPmBFnxJ+o0oSG5xmGSeuf1J1iTx8JC08
         8kwOezCiXN9QVbVLAJsYFgwgSSKvXOnTZPhB186DItDAgAcGXnsPHHU7GfglepUhs+iw
         z8QA==
X-Gm-Message-State: APjAAAWyJmmwFu+PhcOjQKF6K7xl3hUlf+wkHUFuLj1cK7ClQ0QN7IPd
	AeLZtcD18vwtjKhMQ+KC0Po=
X-Google-Smtp-Source: APXvYqyI+etnk5089VErOMk8XqgTxfwAkSptHHANrHUw1yrHJeZLiH5w0UkWbcFYiSOmm16KjfaZlA==
X-Received: by 2002:ac8:6b8f:: with SMTP id z15mr4797796qts.62.1565885534276;
        Thu, 15 Aug 2019 09:12:14 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:25cd])
        by smtp.gmail.com with ESMTPSA id a21sm1430581qtj.5.2019.08.15.09.12.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Aug 2019 09:12:13 -0700 (PDT)
Date: Thu, 15 Aug 2019 09:12:11 -0700
From: Tejun Heo <tj@kernel.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, hannes@cmpxchg.org, mhocko@kernel.org,
	vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, guro@fb.com, akpm@linux-foundation.org
Subject: Re: [PATCH 3/4] writeback, memcg: Implement cgroup_writeback_by_id()
Message-ID: <20190815161211.GC588936@devbig004.ftw2.facebook.com>
References: <20190803140155.181190-1-tj@kernel.org>
 <20190803140155.181190-4-tj@kernel.org>
 <20190815145421.GN14313@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815145421.GN14313@quack2.suse.cz>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 04:54:21PM +0200, Jan Kara wrote:
> > +	/* and find the associated wb */
> > +	wb = wb_get_create(bdi, memcg_css, GFP_NOWAIT | __GFP_NOWARN);
> > +	if (!wb) {
> > +		ret = -ENOMEM;
> > +		goto out_css_put;
> > +	}
> 
> One more thought: You don't want the "_create" part here, do you? If
> there's any point in writing back using this wb, it must be attached to
> some inode and thus it must exist. In the normal case wb_get_create() will
> just fetch the reference and be done with it but when you feed garbage into
> this function due to id going stale or frn structures getting corrupted due
> to concurrent access, you can be creating bogus wb structures in bdi...

Yeah, it can create wbs unnecessarily which isn't critical but also is
easy to fix.  Will update.

Thanks.

-- 
tejun

