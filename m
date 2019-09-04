Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0781FC3A5A9
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 20:04:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A452722CF5
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 20:04:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="r2Y7xKaR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A452722CF5
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22A456B0003; Wed,  4 Sep 2019 16:04:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DAC26B0006; Wed,  4 Sep 2019 16:04:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A37E6B000A; Wed,  4 Sep 2019 16:04:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0028.hostedemail.com [216.40.44.28])
	by kanga.kvack.org (Postfix) with ESMTP id DD3636B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 16:04:09 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 25893AC1F
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 20:04:09 +0000 (UTC)
X-FDA: 75898314618.02.car65_414b75ad35254
X-HE-Tag: car65_414b75ad35254
X-Filterd-Recvd-Size: 4263
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com [209.85.210.194])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 20:04:08 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id y9so13990490pfl.4
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 13:04:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=vUq6q5rLq1rpkR2Aq011wdvO0ya+rjWQxpONqV3eZoc=;
        b=r2Y7xKaRnaJsuxJ7d1X1sjgGndZKPqGSY4mHbfjimxEe/js2y0q5xwh5Ofo9PObnOH
         jFpmg3gyfWrbsH37smwNTwt5mtQ7zZl4z1sWxsqmUyy5Mhvg3nE1P2qr78dtqaf+aBQj
         cODk1OIu/HjuyGk/UREUeGXrMX/xOWcIvnAfoHJqX4x+wvkaPVeiOfqtjlNupPrMiCxb
         jOyVP6fHwuS49HdTbhlntrWEDX+6trfxMOhCtErqNnkgNLk8eC/Rsa7iP/dAiUfhR6OI
         YBgVwSjUP+XApsFL96rAT6NYMu7YH6hZXFSpuhRHm3viz0Gbre8xPWQE4PNP1rXjMxmY
         A7HA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version;
        bh=vUq6q5rLq1rpkR2Aq011wdvO0ya+rjWQxpONqV3eZoc=;
        b=ZNX2kKSIDN8K/E52i2Nj2Xr/MXPvlB9tvLsplFF1ji2s52wruo/+CIYA80KKAFKcyN
         k62WnEGpz863ZKoRdfrLwGZFFxl82Z4++U6fJQqpGmmSaNDwa1eeqMLLIsZNhyGzRB5K
         YEPptzBhYwqGfUAi8hgdSIyNG2C19m9NtrN+nyMUQBUgKhTWKdNcckYaQe/nJIEPrhW4
         QTY819AYVscoiufmS9/51JRVVRDb1iqEcYfH9lMubJBcGIAGynPpk4gkIlCY2RcunGmc
         3yhrQyQTcW6J8PtnWu4M1BEPKSh0sPdS7GebJirIxAyM68QEoJKiWXBRUyJ+43GzDpGf
         VWlw==
X-Gm-Message-State: APjAAAVCcxJlh5YsJffjOjUmEXRkiG5TJoTMIeMxsAjlS+3CmvWpOgPO
	n5taAWGvfBzYlNvk4BdTbYyXgA==
X-Google-Smtp-Source: APXvYqyqELoTqEWKwQaumCgh6k1NrXvt9u9MsAHYP8pjOnJ1PHEhirUkRFSaBs5dgKx5iMe8RjiwPQ==
X-Received: by 2002:a63:2a41:: with SMTP id q62mr36843166pgq.444.1567627446279;
        Wed, 04 Sep 2019 13:04:06 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id m19sm3043700pjv.9.2019.09.04.13.04.05
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 04 Sep 2019 13:04:05 -0700 (PDT)
Date: Wed, 4 Sep 2019 13:04:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Michal Hocko <mhocko@kernel.org>
cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, 
    Andrew Morton <akpm@linux-foundation.org>, 
    LKML <linux-kernel@vger.kernel.org>
Subject: Re: [RFC PATCH] mm, oom: disable dump_tasks by default
In-Reply-To: <20190904054004.GA3838@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1909041302290.95127@chino.kir.corp.google.com>
References: <20190903144512.9374-1-mhocko@kernel.org> <af0703d2-17e4-1b8e-eb54-58d7743cad60@i-love.sakura.ne.jp> <20190904054004.GA3838@dhcp22.suse.cz>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Sep 2019, Michal Hocko wrote:

> > > It's primary purpose is
> > > to help analyse oom victim selection decision.
> > 
> > I disagree, for I use the process list for understanding what / how many
> > processes are consuming what kind of memory (without crashing the system)
> > for anomaly detection purpose. Although we can't dump memory consumed by
> > e.g. file descriptors, disabling dump_tasks() loose that clue, and is
> > problematic for me.
> 
> Does anything really prevent you from enabling this by sysctl though? Or
> do you claim that this is a general usage pattern and therefore the
> default change is not acceptable or do you want a changelog to be
> updated?
> 

I think the motivation is that users don't want to need to reproduce an 
oom kill to figure out why: they want to be able to figure out which 
process had higher than normal memory usage.  If oom is the normal case 
then they ceratinly have the ability to disable it by disabling the 
sysctl, but that seems like something better to opt-out of rather than 
need to opt-in to and reproduce.

