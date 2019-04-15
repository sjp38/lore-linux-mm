Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AAD4C10F0E
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 11:42:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44A252073F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 11:42:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44A252073F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D6B066B0003; Mon, 15 Apr 2019 07:42:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D18A66B0006; Mon, 15 Apr 2019 07:42:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE2256B0007; Mon, 15 Apr 2019 07:42:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 81A8E6B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 07:42:15 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y7so8754678eds.7
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 04:42:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0edKX41L0bjr2s/KYkBg1T/qQB7yedkiy8zjrxU80d4=;
        b=CKwOIXheueBBO0arBa9C1YYLzJH+lGF2wZ/rCFt2Z5/ToQ8oUKjkQbTBnVguYEwe1o
         /VrYO+Px8J57jsTjhU4NHrP0Tk0RIH4NOT8Fmk4P+IqZ146d77qXWwKL6TmtBV8fL5d3
         VLCvDre5c7L91xeoQjG90ljY9JN7QAJLleB06aOVY1n5AHNLEdOaKvLs1Q71nnz4THHE
         8jCnWKlSd3sCVUlQeKwglFDNoN/1sOfcopmwaSnAhxprfq08GQ5LnUDnGdhx+MPbyDp4
         StyB/jJHFH1Woo0e3b0bBjtwNl7/Kerf5hCDrSe52XklwOGRgorUu2Etxdis9MqpE6VG
         T/HQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXIZ0Qw+wa7pnIf64CEUcqeIUHjy28AdcYksrXU9VWq6XSEIyS9
	upCY5MCK20+wzchK7PeCzoiSYO+OD+ygsdexiz3m9ic9yRX3EMRsfAdkSiCe6cl6iZ25y/L5d/K
	z/cnmBacQGlP2xg6H08v7SQwFrzm7GDtnbv+fZCrEHpRGdPx14PA10icl4N73Fzs=
X-Received: by 2002:a17:906:7e09:: with SMTP id e9mr21966920ejr.148.1555328535004;
        Mon, 15 Apr 2019 04:42:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqytvIpfrSzrYMxNaKx9I9zD3q774objwY7msG7Ki3mOjIQQzNpeIpH8BQRo8cKSW4ZvpTJi
X-Received: by 2002:a17:906:7e09:: with SMTP id e9mr21966868ejr.148.1555328533794;
        Mon, 15 Apr 2019 04:42:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555328533; cv=none;
        d=google.com; s=arc-20160816;
        b=1AACw9ls+Bfou31AbKoGaTYo8ZxOG4Bbq7lnmtx/O2h/aXH98BtmfpdTrcQ/6/m1TO
         20AmtYdRNznph/3D1Bfo57YolY0OS8eh+TlUCdwcbWsxoaufmy4taBlykdkzxRcYQOMS
         ngxWisfSorLItwsVFL8e+pSPp/vz9Gb4R1mDF6dgr/KR2d+DprfgezaOVmjg2HUS/4o7
         pM7AM/TQiFzad69EGU/2k2NHjx63UuXs3Ihq9bt9n4tBHcinpRvIRvOCI2xt3DkErITv
         L6oYXdY2GcmstJuY0urdgzW0RfepxsC27XsVXhIBNuiyYUioVzZmItuioWOubIq2CTVe
         aNcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0edKX41L0bjr2s/KYkBg1T/qQB7yedkiy8zjrxU80d4=;
        b=jrxCw6DKpYjbLFJIFqwLtUnw4d7ig0SyLJ9U2BFidRpWgJA1B3vq8vFXdwesDojUsy
         sw4Ofn2s/kD9Zx9nQ8S2oC6Vt/Dc99EmlSU/uP7i7qi17c/um8erUQthLMzsbaHwDrHs
         3lpGB1HRz+5ZO8J7R9pEwbKCctPcYvMKli8HJIH9850Wr5/OQqaVhpQ5F2tuyp3+yFdw
         KrDrb56o9zRJjUJRQIdJFDLn78Z7nBq8RF0LDKV9hQ99Opshym0uDwQoEe/VlxiuZjkM
         yP9hUMOgiXAplzLJRbHALQffMqay3wNfNY0d75JLHE7RpsL1S4ufxt+IOhaqgVCdqA8w
         e5XA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t19si1873317ejr.240.2019.04.15.04.42.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 04:42:13 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1C86CAF2F;
	Mon, 15 Apr 2019 11:42:13 +0000 (UTC)
Date: Mon, 15 Apr 2019 13:42:09 +0200
From: Michal Hocko <mhocko@kernel.org>
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Dave Hansen <dave.hansen@intel.com>,
	Peter Zijlstra <peterz@infradead.org>, x86@kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org,
	linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/2] x86, numa: always initialize all possible nodes
Message-ID: <20190415114209.GJ3366@dhcp22.suse.cz>
References: <20190212095343.23315-1-mhocko@kernel.org>
 <20190226131201.GA10588@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190226131201.GA10588@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 26-02-19 14:12:01, Michal Hocko wrote:
> On Tue 12-02-19 10:53:41, Michal Hocko wrote:
> > Hi,
> > this has been posted as an RFC previously [1]. There didn't seem to be
> > any objections so I am reposting this for inclusion. I have added a
> > debugging patch which prints the zonelist setup for each numa node
> > for an easier debugging of a broken zonelist setup.
> > 
> > [1] http://lkml.kernel.org/r/20190114082416.30939-1-mhocko@kernel.org
> 
> Friendly ping. I haven't heard any complains so can we route this via
> tip/x86/mm or should we go via mmotm.

It seems that Dave is busy. Let's add Andrew. Can we get this [1] merged
finally, please?

[1] http://lkml.kernel.org/r/20190212095343.23315-1-mhocko@kernel.org
-- 
Michal Hocko
SUSE Labs

