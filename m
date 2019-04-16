Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0CA9C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 06:54:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A84B620675
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 06:54:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A84B620675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 354966B0007; Tue, 16 Apr 2019 02:54:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3041C6B0008; Tue, 16 Apr 2019 02:54:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F3A66B000A; Tue, 16 Apr 2019 02:54:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C3EF26B0007
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 02:54:37 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id m47so4364402edd.15
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 23:54:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ejIrGp9WtaNLPMxJWAUQhN+EOY3z/oSIfng3Mvgt24o=;
        b=gYQFEDWsob0kE8UFvWnwGSpoD1Nx59uOPAHLCbX/qU88DmrmdUF3IS+M7dvHs32E3r
         c3K2UB1VoOaYgwjpPq/fRzcnVGDUF7VPVbXEhuY5kyoGszHxechJj5ZxWcHlINSsDXYv
         UZPR5P2jqKsHr7YKoVT0lHn4OUmdUCWV3GUaXoJ37Xy5oyGwP1JwcIINY0GEzQlfCveJ
         3jzlxcHmhhCXnj8FK8tfjVPixEbuOKdHEtB2K532p8EFx8+xPTH0gQkN/YRATKVANXYJ
         RMEcQXK+AIisAv4Ojryr+x7q/hrM3bG1QVnsExmUsEgClKbFWVxnnoe7ukZzEc6amKqj
         LtwA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWxJgjlNsEcRv3eRz1Ohsfkm8MP2PEHbZv7f9w+76NPoC//UuRf
	65BQfNv6hDtMJZBuvFfp/D8VFLnkVJReya8L3HPG43GLsr+daSvk+WlNhzFZ9Nh9ihePkfz6O8e
	Uzt39l7s1lzq4onqk+efEjIFoah13AzxmQeIPBvqp7PrfCKawyA5hhxsvB3YLIyE=
X-Received: by 2002:a17:906:54c3:: with SMTP id c3mr42931514ejp.72.1555397677325;
        Mon, 15 Apr 2019 23:54:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+BzqQYxWVI86t/JIveDYu8uXq8a40OEEZfTm8zC6l1CusXz88q0OLnGP4UzORg0S+eInJ
X-Received: by 2002:a17:906:54c3:: with SMTP id c3mr42931480ejp.72.1555397676424;
        Mon, 15 Apr 2019 23:54:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555397676; cv=none;
        d=google.com; s=arc-20160816;
        b=s5RwKaO8xpplSrVKwT5PfPlwyoBx/zXLxt3uNiID9k745OWLw91maN10RFWQpzEb1z
         gyeQXV00hDsosiw+dO+MaAeZ4IhCjgfTFG2fINnlArKXNxoSBbWQQ9OIgoOel/5Ln+S3
         ZX8JQNumpq9Er7NzgqkOFLzfDNQQaUJb7VvTEXkTXHNj7H6K+3QWSlEU9FralsEwF0IN
         F9SuNRgo9u54R4cE/TbuvBiWrIzqKMfrL8YWxoolv+C/Y1Hw7BoDVY+6K684Nb74TFLg
         /qT7Itv7oqWKZD7+hK0Aoiz3NmRXhRp3zNYArRhHyc6Fcxh4v65CHH6d2mK+xoj5ot7Q
         ff5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ejIrGp9WtaNLPMxJWAUQhN+EOY3z/oSIfng3Mvgt24o=;
        b=thkVzIK0083qt7X9Xn57HgeTsbmzEOR/WBCLTCEfIBvh9QkPhfMoa/8N4KY6R/Ynie
         B4IKR6nmzwkLNe7ND/sYNrGaaPorMtF/ErrQjz6E69Tuz5kwHryR4GzOVa5RLapNcKIh
         sagFxors+ofTN/kvvmyaLVzkz2KaQpae9b+TeRzsQHjSJZOGd5kZ/07CXj9u+yEYe0Yt
         M3f18XoN1d7ucGhtJpbpUGvzEerfTMMZS5TaVWaCXl1pRAsopYfn2eVGaF0gGA5Q9wtI
         kI0CfNNVo2ityRPrrmUAqONIOiz3l0EmpVDEmJ0wUl87o5qPaeh2BJhFmUn6UUGQkrHM
         9s2w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d7si703410edx.319.2019.04.15.23.54.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 23:54:36 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 99D90ACD0;
	Tue, 16 Apr 2019 06:54:35 +0000 (UTC)
Date: Tue, 16 Apr 2019 08:54:32 +0200
From: Michal Hocko <mhocko@kernel.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Pingfan Liu <kernelfans@gmail.com>, Dave Hansen <dave.hansen@intel.com>,
	Peter Zijlstra <peterz@infradead.org>, x86@kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org,
	linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/2] x86, numa: always initialize all possible nodes
Message-ID: <20190416065432.GC11561@dhcp22.suse.cz>
References: <20190212095343.23315-1-mhocko@kernel.org>
 <20190226131201.GA10588@dhcp22.suse.cz>
 <20190415114209.GJ3366@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190415114209.GJ3366@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Forgot to cc Andrew. Now for real.

Andrew please note that Dave has reviewed the patch
http://lkml.kernel.org/r/77b364e5-a30c-964a-6985-00b759dac128@intel.com

Or do you want me to resubmit?

On Mon 15-04-19 13:42:09, Michal Hocko wrote:
> On Tue 26-02-19 14:12:01, Michal Hocko wrote:
> > On Tue 12-02-19 10:53:41, Michal Hocko wrote:
> > > Hi,
> > > this has been posted as an RFC previously [1]. There didn't seem to be
> > > any objections so I am reposting this for inclusion. I have added a
> > > debugging patch which prints the zonelist setup for each numa node
> > > for an easier debugging of a broken zonelist setup.
> > > 
> > > [1] http://lkml.kernel.org/r/20190114082416.30939-1-mhocko@kernel.org
> > 
> > Friendly ping. I haven't heard any complains so can we route this via
> > tip/x86/mm or should we go via mmotm.
> 
> It seems that Dave is busy. Let's add Andrew. Can we get this [1] merged
> finally, please?
> 
> [1] http://lkml.kernel.org/r/20190212095343.23315-1-mhocko@kernel.org

-- 
Michal Hocko
SUSE Labs

