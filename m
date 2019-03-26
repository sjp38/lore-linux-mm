Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D719DC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 08:40:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92DAF2084B
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 08:40:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92DAF2084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F9F76B0005; Tue, 26 Mar 2019 04:40:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 280D16B0006; Tue, 26 Mar 2019 04:40:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1498F6B000D; Tue, 26 Mar 2019 04:40:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B9C166B0005
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 04:40:42 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y17so4934349edd.20
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 01:40:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=nPFDsZq+xjYpx1b+tqtt91I9H/tSBp9VsyD4HSwtK6g=;
        b=tsitxspM4L2F/q8uBi+dj0WgFNi8R5A6Fni4KiKb2n70MCa2zR0osCPtQ41kMjCt6z
         90wFE1GIL+tx+mJqa3LaO6hMLyY9CdqFsvEkgvAUBgStYbpBFyRwjGZntUfA0aQ7p4yJ
         Zko393zlkmDmwryKW1u/M8Ba5G4kWiGvQwyXrRx584imW2AhFkUbw8jH4Owrnw+pwnAq
         3PQbGq3CshAOhb5TGvA+rY4/AABXmWpEZJPRuBEZLTMERbKQq3pZKSBJxQQelvBZW5UM
         l1F8Wm6VS2fSj7GRaT2N4kurnM0w3YO9O3DrrW+XKeCY5NEeuTXjTOeu1DeYhu5hfa1z
         aQUA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAULH2ebIGzSNLCahfF337sw24NsxG+mjaMgag30DXLjkmdP3olS
	pmF25YQXBgDlWsl9oSyaJNBhnBb44G377MprUKWsLjBvkgRG7NyADqFy42PLoXarcmhpT66lDz2
	PhBZgiGzxiUMaPFwYHGVx265dCNO9kIYQnHHRlHtmGij0s/whqzs6ypZtW+Lq1sc=
X-Received: by 2002:a50:9473:: with SMTP id q48mr19714841eda.290.1553589642275;
        Tue, 26 Mar 2019 01:40:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxEPSqbhR7Y7Se29qJeUsJ6ngVTSNHUFSWdx1TTOzHsPdeYpj7kMgvL4U6bZUlWxbsKbwBI
X-Received: by 2002:a50:9473:: with SMTP id q48mr19714810eda.290.1553589641629;
        Tue, 26 Mar 2019 01:40:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553589641; cv=none;
        d=google.com; s=arc-20160816;
        b=VBHKttpE/n9+D5Z6wi7LS9XKG4xvz4GpQMXIGs9Ek/a9MuiYkIBs5VcWp7um6X6R/o
         MRPmlnRKlinpNuD6iTWbW49eFDipUpsrrm+UgC5aDvZ3llHy6nQiYrOB6t9RttKbEExt
         +QO3c2OhO3jtu3HVZab4lQEvIa1ivffrXnbuP5FUlWx02t7vgHhYZdBg8SVCbcyxWfGR
         etMQTmyMUHveUT7m6DBgea60YVsZMO33RMa1JOqj6RUuQr9QS00bRBUO1DYioKZXb2aA
         EJrIOtnHOWmJ+GDjhXEV+85t3v1ePXnd70axJSpcPK5Qj8hssjz7ER/Vtx0Z9ZHVHk43
         +CAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=nPFDsZq+xjYpx1b+tqtt91I9H/tSBp9VsyD4HSwtK6g=;
        b=r6krfoNH4R+XIHYRboBn7AAUjr54b+KmvL+G9MIJE2d/Yh+Lge/RGYs19kl4Xeo13E
         i+OsX1THdw6IeTEZAwTrYP9Y0LaGn5a7ifB4gSdrpaD072SOMERmWiixK/RKXnhKE7EG
         5nC2xmg9A0jmSAjC33Qvw8V2rBfRP/DM5hHn/28CbmpqGMT/bNer6I8R4zjSE7vvUj5x
         23geChx/ta/54+mxw0xPDUHaeauLEo6GjFVihOyfF9hjO1oRBQ8MCG31MbSzEAsndR+J
         u/ZuklwX4vprhHPJDwvv+UbAjCjN1T0pVkcxXS/uLgHb5IJ/qiK95fQ5YRkDxCqTA9B4
         to0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j7si2271167edh.246.2019.03.26.01.40.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 01:40:41 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 25635AD47;
	Tue, 26 Mar 2019 08:40:41 +0000 (UTC)
Date: Tue, 26 Mar 2019 09:40:40 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Vladimir Murzin <vladimir.murzin@arm.com>,
	Tony Luck <tony.luck@intel.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: early_memtest() patterns
Message-ID: <20190326084040.GF28406@dhcp22.suse.cz>
References: <7da922fb-5254-0d3c-ce2b-13248e37db83@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7da922fb-5254-0d3c-ce2b-13248e37db83@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 26-03-19 13:39:14, Anshuman Khandual wrote:
> Hello,
> 
> early_memtest() is being executed on many platforms even though they dont enable
> CONFIG_MEMTEST by default. Just being curious how the following set of patterns
> got decided. Are they just random 64 bit patterns ? Or there is some particular
> significance to them in detecting bad memory.
> 
> static u64 patterns[] __initdata = {
>         /* The first entry has to be 0 to leave memtest with zeroed memory */
>         0,
>         0xffffffffffffffffULL,
>         0x5555555555555555ULL,
>         0xaaaaaaaaaaaaaaaaULL,
>         0x1111111111111111ULL,
>         0x2222222222222222ULL,
>         0x4444444444444444ULL,
>         0x8888888888888888ULL,
>         0x3333333333333333ULL,
>         0x6666666666666666ULL,
>         0x9999999999999999ULL,
>         0xccccccccccccccccULL,
>         0x7777777777777777ULL,
>         0xbbbbbbbbbbbbbbbbULL,
>         0xddddddddddddddddULL,
>         0xeeeeeeeeeeeeeeeeULL,

This are setting different bit patterns, a single/two/three bit(s) at a
different possition of the work.

>         0x7a6c7258554e494cULL, /* yeah ;-) */

Looks like an easter egg string to me.

-- 
Michal Hocko
SUSE Labs

