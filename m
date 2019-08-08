Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9AC6C32754
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 17:04:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9776A2184E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 17:04:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9776A2184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EE8A6B0006; Thu,  8 Aug 2019 13:04:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 277126B0007; Thu,  8 Aug 2019 13:04:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1178F6B0008; Thu,  8 Aug 2019 13:04:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id D150B6B0006
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 13:04:40 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id l24so45444742wrb.0
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 10:04:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=oZtd9li/rmgDDfnvLylCZDgph3rv3KS0O2ma0ykwRUY=;
        b=GT9vGaP0hV9iRctdG9opSwv4Sz4Ig8T/CCmIiyT6EXpWqid/3Jq087yfTgXEIooQIt
         ZbJUJ3/w9CJnAUhNuzwdxVhardDaplGWWZsJZTwB3fDw2M+rpgCxIsHg1ZUZjCzWn1LH
         yiHBxVqP5kAxBMoRgSKd1EtJPhVKPtgHG73WrcqgwrnzBNuySIOyf1uuGekWccHyf5MY
         2eJeFRULn7ehwsTVjiIyALSweBVS4RO3FZQt8LXA/GbRvotSsgLDYdOpHh3pQ4isyOxN
         bli7JFYG1yNTm5GdzZfAzPPH8EYHDa26z6J6kPPk8GjxUIjrmCUD+7XWJscMkeBnPkAt
         1DPw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.222 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAXHXSjB71n2FaDmHMfgodSnhUbkm9O+Th4OjKV+dB+yinMcF6o4
	Ej5sbsdBwawNzsCSLfK2Rq0pvy1MRf/PRF9yQh6zbn0AAQFOtytSUgNyS0nBAB5OIQCBbeeYU/o
	xH4G8hafvKwXEpRngrwyfOnr9FFCqAEuoR3+ucF0HgVZQ8p8Sn0AgaKqxu+qmZLh/+Q==
X-Received: by 2002:a5d:4492:: with SMTP id j18mr15619088wrq.53.1565283880462;
        Thu, 08 Aug 2019 10:04:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0ZVoCEdttQEzNRR/QrxDltEDVWP9JFjcwDxJGJNM7La3PmxAsydccELRNAdI1Ud+YEwME
X-Received: by 2002:a5d:4492:: with SMTP id j18mr15619019wrq.53.1565283879831;
        Thu, 08 Aug 2019 10:04:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565283879; cv=none;
        d=google.com; s=arc-20160816;
        b=ANohouCGbElda+KDcthaGbZ+Ug7fGk2lrl6KljsPrRqdP851S/wzqQicg7LH8gTIOF
         BDDP+Jg/W8RFhhGELAXE90L0Vg9l0UW8y1FtBv30w4CRotvLnffSCMOijBO6Kq5piy/E
         R2mA1J1+Xciah/4HyHxYShZMoUAeHDHrmXumzHtFwYOXVnn0cirFgin6ZLpSI0HGtiPL
         3bPCf+EvIAjtKf5ZoAS2sEd/vBp07nE5smgfCyhTUbexdkkRLvt80mH/Kv2xA1k+Y8p3
         Xcrz66F3JQLV0O9wTCucVyFZxaqk+9NngFqGqCluMfdv5iVZD8iafFm6Wl5MhXet65xP
         3K1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=oZtd9li/rmgDDfnvLylCZDgph3rv3KS0O2ma0ykwRUY=;
        b=esHaO5E3jGfJ3yh3LujKL6HWprNNazq7EuubRGT6iYgydA32FQNcHWoJhflbCdfivX
         53R1fv877LpsXNIgKyCzwBk+BWCv3oqm1wZYSFULGcUBSvusqMtXveFm6XXBVisOzaLl
         1zK6nNwTLaF92m1m3q2gA1P1cscVZhIH3um7UKbO5Gw4tAPVPG0RDzV9WTNY8CGsaPqh
         Q/IoPqhSFs/dtUUUhqRWfLY7vWg3LIlECABZ8mMSjkEKS6JMXLJY+1lWWH9eOHRc4VPk
         QSs2PbutlVPm00s5QKsqm9oJV6/phSr7c7dQJnaMQMxhdEaEJRQwOUNnIsAH1C2LhD1r
         0+5A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.222 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp39.blacknight.com (outbound-smtp39.blacknight.com. [46.22.139.222])
        by mx.google.com with ESMTPS id z62si1953650wmg.123.2019.08.08.10.04.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 10:04:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.222 as permitted sender) client-ip=46.22.139.222;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.222 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (unknown [81.17.254.16])
	by outbound-smtp39.blacknight.com (Postfix) with ESMTPS id 651989DC
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 18:04:39 +0100 (IST)
Received: (qmail 23455 invoked from network); 8 Aug 2019 17:04:39 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.18.93])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 8 Aug 2019 17:04:39 -0000
Date: Thu, 8 Aug 2019 18:04:37 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@kernel.org>,
	linux-mm@kvack.org, linux-xfs@vger.kernel.org,
	Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH] [Regression, v5.0] mm: boosted kswapd reclaim b0rks
 system cache balance
Message-ID: <20190808170437.GL2739@techsingularity.net>
References: <20190807091858.2857-1-david@fromorbit.com>
 <20190807093056.GS11812@dhcp22.suse.cz>
 <20190807150316.GL2708@suse.de>
 <20190807205615.GI2739@techsingularity.net>
 <20190808153658.GA26893@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190808153658.GA26893@infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 08:36:58AM -0700, Christoph Hellwig wrote:
> > -			if (sc->may_shrinkslab) {
> > -				shrink_slab(sc->gfp_mask, pgdat->node_id,
> > -				    memcg, sc->priority);
> > -			}
> > +			shrink_slab(sc->gfp_mask, pgdat->node_id,
> > +			    memcg, sc->priority);
> 
> Not the most useful comment, but the indentation for the continuing line
> is weird (already in the original code).  This should be something like:
> 
> 			shrink_slab(sc->gfp_mask, pgdat->node_id, memcg,
> 					sc->priority);

If that's the worst you found then I take it as good news. I have not
sent a version with an updated changelog so I can fix it up.

-- 
Mel Gorman
SUSE Labs

