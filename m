Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F59DC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 17:38:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B7D32147A
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 17:38:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B7D32147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E51488E0004; Tue, 19 Feb 2019 12:38:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E007B8E0003; Tue, 19 Feb 2019 12:38:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF8E28E0004; Tue, 19 Feb 2019 12:38:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 770B28E0003
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:38:23 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x47so8670104eda.8
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 09:38:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Fxab85laaj1ABBYdu5L4VqdLYaPF9cPFVrZVF7A/1Tg=;
        b=unMlzZ877eNqtT0JTmTc2DXmmFR2+PT9nxvYlaGLc88VJFhMGl0TvmFQ7rrbQEat74
         /qWLAuLMGprLRUV8dEkTNbvTUfbqE/cxaqRMGv/BFckr76+Jwxh1nJSa330R39yaX76Q
         NW3s1PFTtpHOn21KBFPGIRpLXpbUfRM2QTPf0fc2lcn1+qxePNwta1irnnDmfrOgOPKa
         +1h+Z4wp2F+o8Uhowntbd/hKI8nGbB2kSTvS4Has9HO0Klh5lfF/9uwI8Bi9QaXAB94N
         MSHn4xIje0bQeDqxc+9awziha1AGVllWVkF9/iE3hw/DkFALKmJGjQTp7VSeiGExvUxU
         2AwQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZdZemdDb1AD8ipCiEu1bFYPSKDddTtkkps/8F0JGx7KR13kD2R
	GiFP85Q6tvOwUXRWP8LSvj7xhhtZ22dbngRzr2shw92UQEPE+PDvscIriwAze0x5gyl6z9ooY34
	uiB2XGIXQwYwy/LFeA9zwJKTIiWMkfL65zetDBO4xom/hTN4/j3m+UumB8sV0SE8=
X-Received: by 2002:a17:906:3d69:: with SMTP id r9mr17039710ejf.92.1550597903012;
        Tue, 19 Feb 2019 09:38:23 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYr7TYgmNOVlbcWf5VSF3uo0m0HCZXSH7cFyCj9JSekda/wGzEDDf4xYfhPTrfKqVVJ+C9g
X-Received: by 2002:a17:906:3d69:: with SMTP id r9mr17039656ejf.92.1550597902152;
        Tue, 19 Feb 2019 09:38:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550597902; cv=none;
        d=google.com; s=arc-20160816;
        b=qvkaR00QKDyzfFmcp2IGSMwMHBoe/Q26g76aZRkKhwZ1pZmNmvM54pPlTQHxDrK04l
         AdfThbzTorSzSMkhrbyEXovC4S5kVZeZ9gMPhFCNXSwIAQq7Ia4o/BwtIx/QkXnyhFTq
         DNxlgkh7L89pzDurDQjMCE0NnozkxC4GTkRe5DjwNnjvjPiVLAJZKFuhVxJDR0EXp36v
         LAbaqpX+7qTufoRFEH72aQoYCMXlQ3+2Xjfx93uU73dzDIbm2h0b3oIGX1u9WVrNitez
         3g6gJmwwd7dw4APsCjp+3zrFX4qMmqBCfKC4roLe9g6Eu01CxfEyVTtOR1G0Q1wQCi5A
         tEdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Fxab85laaj1ABBYdu5L4VqdLYaPF9cPFVrZVF7A/1Tg=;
        b=GB4MY1u8YIWVekKvVtYdpTvPgZkPbTpgG9VnWz1tTSqIjAukznrhl/ZFKFX+Zml+Iy
         bRKfChAa8KwN+NE6Ww44l+eq7gQxyxPd0Xiax9yGNAAwucRldLItyKvGPdn5ebHpsK/8
         fpFOZ1rcvdAiS9VEVglhmh1Ir3tF7LLO85L+dLgjxZxM9cVTU7Pm6bGylZfkbfdJt3zc
         d5JlsLkdGWPDiKr6hoXTH7I1koPbXggbXt0Auitqt70wQsJh0rKT+yLXP15/KFCkNBEb
         2mOyt4crMpIVVFcqbuOh9mfnQHrWNfY3GMPojNA8XDC4cEkyRVemx5rFENyT6BGX7T6S
         4S6g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cb3si1443078ejb.3.2019.02.19.09.38.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 09:38:22 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B0AA7B162;
	Tue, 19 Feb 2019 17:38:21 +0000 (UTC)
Date: Tue, 19 Feb 2019 18:38:16 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Rik van Riel <riel@surriel.com>
Cc: Dave Chinner <dchinner@redhat.com>, Roman Gushchin <guro@fb.com>,
	"lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"guroan@gmail.com" <guroan@gmail.com>,
	Kernel Team <Kernel-team@fb.com>,
	"hannes@cmpxchg.org" <hannes@cmpxchg.org>
Subject: Re: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
Message-ID: <20190219173816.GR4525@dhcp22.suse.cz>
References: <20190219003140.GA5660@castle.DHCP.thefacebook.com>
 <20190219020448.GY31397@rh>
 <7f66dd5242ab4d305f43d85de1a8e514fc47c492.camel@surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7f66dd5242ab4d305f43d85de1a8e514fc47c492.camel@surriel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 19-02-19 12:31:10, Rik van Riel wrote:
> On Tue, 2019-02-19 at 13:04 +1100, Dave Chinner wrote:
> > On Tue, Feb 19, 2019 at 12:31:45AM +0000, Roman Gushchin wrote:
> > > Sorry, resending with the fixed to/cc list. Please, ignore the
> > > first letter.
> > 
> > Please resend again with linux-fsdevel on the cc list, because this
> > isn't a MM topic given the regressions from the shrinker patches
> > have all been on the filesystem side of the shrinkers....
> 
> It looks like there are two separate things going on here.
> 
> The first are an MM issues, one of potentially leaking memory
> by not scanning slabs with few items on them, and having
> such slabs stay around forever after the cgroup they were
> created for has disappeared, and the other of various other
> bugs with shrinker invocation behavior (like the nr_deferred
> fixes you posted a patch for). I believe these are MM topics.
> 
> 
> The second is the filesystem (and maybe other) shrinker
> functions' behavior being somewhat fragile and depending
> on closely on current MM behavior, potentially up to
> and including MM bugs.

I do agree and we should separate the two topics.

-- 
Michal Hocko
SUSE Labs

