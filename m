Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EFD0C3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 15:58:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40FFB217F5
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 15:58:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GnZUYkQ4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40FFB217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC8526B05AB; Mon, 26 Aug 2019 11:58:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C78A06B05AD; Mon, 26 Aug 2019 11:58:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8FB06B05AE; Mon, 26 Aug 2019 11:58:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0165.hostedemail.com [216.40.44.165])
	by kanga.kvack.org (Postfix) with ESMTP id 986616B05AB
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 11:58:38 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 4E9036122
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 15:58:38 +0000 (UTC)
X-FDA: 75865036716.18.lead03_112d9f60a3254
X-HE-Tag: lead03_112d9f60a3254
X-Filterd-Recvd-Size: 3754
Received: from mail-qk1-f194.google.com (mail-qk1-f194.google.com [209.85.222.194])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 15:58:37 +0000 (UTC)
Received: by mail-qk1-f194.google.com with SMTP id 201so14418220qkm.9
        for <linux-mm@kvack.org>; Mon, 26 Aug 2019 08:58:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ualaw3vnF7au6b9X5hx4CHQJfw3fBI27o57pEiUgbJo=;
        b=GnZUYkQ4vVP/v3mu6UxwHdso20ta7Q+KhSdq+8YuwnxdWNjaUmry5GKa9icK1tWcPe
         i/Pa4V+XigAXejuiA1uK/adIfsd3tDcx7eNQWCvIoM7+QHoz4QqAu7XMNSgL7N8+zqdE
         Ok9jG1XQ3c//jnZbPEfKOODlmHb3a7fgG1xvkLv2WSTgnTZ0rDXfwKvAOEvY1x+5qNmd
         pm1xCF4GvRicJfJDbO+EIuu1fTxJrTXW/dSfkGdSesws3Z7Jjp9PFSy+eyS5KifycqKL
         eHHWeEryOX/9dFa/d+Z/gnxpRShYwQ/t30umzlPd2vtUN8mYXy8+GKymvgk7N/3qzv5V
         v2Eg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=ualaw3vnF7au6b9X5hx4CHQJfw3fBI27o57pEiUgbJo=;
        b=hyoSM9kb8OY2hRiKGqJVmlxwBCxeW0A3XiS1HEAU5ERs+xyWiq1ZzTMuW8YbR/ohj8
         HfxyVA2Tn6ppb6I5GbaO1k33nVL2A54D1f3ZWLBIs2VhgB8gksRTQQyOl+ABXUpohKes
         rjvK0gDuSlBeRaX0FyKltTEeoriTjXDt2NW9JUS4oZOS1HGqSKczgAA/OE8lEdEYc8iB
         4AOQItN7Mvajz6LnVoJNoKSnkvip6HHgwD803EqjLgbFepvwH8cZCaY9fmZW20hTN2H4
         FtfZZ8lSnttbb0trhkxJj3Iw3uOD81T0qmg/6UaJn4qttuIBFBsSY1gx1JeeJR5Kk463
         UdGQ==
X-Gm-Message-State: APjAAAXzHGdJpo94HUu7imN4Q7FjnuPXnZMwTUro+OvqbtP9ZnxofD5Y
	nj4+xTRgov0j9FZrexjI/qU=
X-Google-Smtp-Source: APXvYqzk/P1DVpjgy0hFgeWPetp0WfMSK+IUiMif/29MeRJwYBpNW0Jt/njmIG/Lg9zleKegbXPjwA==
X-Received: by 2002:a37:6290:: with SMTP id w138mr16091986qkb.139.1566835117260;
        Mon, 26 Aug 2019 08:58:37 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::d081])
        by smtp.gmail.com with ESMTPSA id y25sm7676497qkj.35.2019.08.26.08.58.36
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Aug 2019 08:58:36 -0700 (PDT)
Date: Mon, 26 Aug 2019 08:58:34 -0700
From: Tejun Heo <tj@kernel.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, hannes@cmpxchg.org, mhocko@kernel.org,
	vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, guro@fb.com, akpm@linux-foundation.org
Subject: Re: [PATCH v3 5/5] writeback, memcg: Implement foreign dirty flushing
Message-ID: <20190826155834.GP2263813@devbig004.ftw2.facebook.com>
References: <20190815195619.GA2263813@devbig004.ftw2.facebook.com>
 <20190815195930.GF2263813@devbig004.ftw2.facebook.com>
 <20190821210235.GN2263813@devbig004.ftw2.facebook.com>
 <20190826135452.GF10614@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190826135452.GF10614@quack2.suse.cz>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Jan.

On Mon, Aug 26, 2019 at 03:54:52PM +0200, Jan Kara wrote:
> As I've checked, you should be using get_jiffies_64() to get value of
> jiffies_64. Also for comparisons of jiffie values, I think you should be
> using time_after64() and similar functions instead of direct comparisons...

Yeah, good point.  I always forget that with jiffies_64.  Will post an
updated series soon.

Thanks.

-- 
tejun

