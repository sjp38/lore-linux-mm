Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4ACACC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 09:44:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 115A1218AD
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 09:44:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 115A1218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 919DC8E0003; Mon, 18 Feb 2019 04:44:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CA278E0002; Mon, 18 Feb 2019 04:44:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B98A8E0003; Mon, 18 Feb 2019 04:44:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 222FF8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 04:44:57 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id a21so5665786eda.3
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 01:44:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=5LqI7aQ1ZSaM9l1iY2nd26kPlSpwxuoQvp9Pu19VX4E=;
        b=LjmHh2sa16ryJkWx/Ud1V/NcnQIM6EG9wf3+qFIjbCf1cR3pDdGG2ZWRKOVpihy710
         2R1QVSF/tad5/LUXz52CklkuVQTu7OBdpt7KYAlD1+6mOSkp2PKudWBBY9MuiikhLYyS
         7IMIDA+t1fduohCgK94Nz2d9jsJ9suvJf7nUfmFbXYggcWaUoAmTfJZSV8iSQUFBoCUw
         yoDsUOjWetSEqAVe4/y0jvjf/UNfWllXPxCfAj0S9isE7hF2Dg2ycs4hG4LapmKdfFX/
         GGdSmqSCWDn7l8vLQY1moBAvyyFLZUNEfYmNINRee/DjNi2d9KRln1ex40OT3u9l2K4M
         tO7g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZgD8zDSy7+DRM5ljLII5nuqIIYG/P7dxuATp2mmkEN9FyfBcuZ
	A8TnnrF3mXJv8+i5r46Rn+Y+UFTxAxJfLs0BnZKj2uRVKSzPbtHSwtumorTysmALxOk3TKad+3S
	TREoInhig7R0k+p3TRIFFzdwlnV5IwTDYNhm4aYcW0EEZ7PrF090NOU7K7HeIpZs=
X-Received: by 2002:a50:ae63:: with SMTP id c90mr14905843edd.285.1550483096684;
        Mon, 18 Feb 2019 01:44:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbHPL849f6ezW5oiuN0d0zNdb3tsetDIZGw9lwfT9QKLlkGYbzWj3SdiF0Q7vBMQQkg/b/K
X-Received: by 2002:a50:ae63:: with SMTP id c90mr14905804edd.285.1550483095771;
        Mon, 18 Feb 2019 01:44:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550483095; cv=none;
        d=google.com; s=arc-20160816;
        b=N6br0AiGhWe1kjSab9fPYh5FNQMgEIyFcbHjUzIfGpDTBs9WLga0OvpVpNEDrTYYRc
         lmW1rlraIYcLXXoRysrFYSSNg3Y7kKcjRIRvM9pID+gbC1nukmQ3WJAdOsjU00QopCaT
         tsdRi1W23rQ0s7UqqDKi/3nByOa6QA17sZGB50dimZz6F+9f74QVacFdwxT3cL59SnWX
         wGC+QrsTeVedjH17an59qZRl5H+AClhrJlpNsYmMICE6eleOADbref8AhTGS+7Nron1U
         CmB29xEqz8rFybzyBwtXUo5UdZh5u7koDFZk98cZlwPEXtIFuv+UU6qKhhlnnQC2zFRC
         2XJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=5LqI7aQ1ZSaM9l1iY2nd26kPlSpwxuoQvp9Pu19VX4E=;
        b=s5p1skRQn0eSy10ZNBVCh9pS0N7zPknXruPC2HYjfuI0LOo1kZ+HEw5gWplvfJmWrD
         EW9sLkPFVkFz1Pz+fQg89B+J3WPQmuoR/3NbLrG4oLyX6NX2piBDxTGxbVMHeaGQf9zF
         KJXg3kfxomJIQtxITmXnU5PRo8UrVLtgfhJcjovR57GY4ymEp6Xuc8rXLQ7nDfLCoqrF
         hx8iIeRPgPOSBBF7Z7QXuS5calhxQW6jBM4bMZwcyIzAsagAc5csuGNcoQM8Ngz/kHGQ
         rfR3CGmiqRy1vZO7eJ32yInY9DUNjtmYV1H/M3ZcfsQo6BpZzqWSYRIFYc6J+Gkve32D
         8qrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t12si3894208eju.145.2019.02.18.01.44.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 01:44:55 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D0FA9AD18;
	Mon, 18 Feb 2019 09:44:54 +0000 (UTC)
Date: Mon, 18 Feb 2019 10:44:53 +0100
From: Michal Hocko <mhocko@kernel.org>
To: "kernelci.org bot" <bot@kernelci.org>
Cc: tomeu.vizoso@collabora.com, guillaume.tucker@collabora.com,
	Dan Williams <dan.j.williams@intel.com>, broonie@kernel.org,
	matthew.hart@linaro.org, Stephen Rothwell <sfr@canb.auug.org.au>,
	khilman@baylibre.com, enric.balletbo@collabora.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Nicholas Piggin <npiggin@gmail.com>,
	Dominik Brodowski <linux@dominikbrodowski.net>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Kees Cook <keescook@chromium.org>, Adrian Reber <adrian@lisas.de>,
	linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	linux-mm@kvack.org,
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
	Richard Guy Briggs <rgb@redhat.com>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
Message-ID: <20190218094453.GJ4525@dhcp22.suse.cz>
References: <5c6702da.1c69fb81.12a14.4ece@mx.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5c6702da.1c69fb81.12a14.4ece@mx.google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 15-02-19 10:20:10, kernelci.org bot wrote:
> * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
> * This automated bisection report was sent to you on the basis  *
> * that you may be involved with the breaking commit it has      *
> * found.  No manual investigation has been done to verify it,   *
> * and the root cause of the problem may be somewhere else.      *
> * Hope this helps!                                              *
> * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
> 
> next/master boot bisection: next-20190215 on beaglebone-black
> 
> Summary:
>   Start:      7a92eb7cc1dc Add linux-next specific files for 20190215
>   Details:    https://kernelci.org/boot/id/5c666ea959b514b017fe6017
>   Plain log:  https://storage.kernelci.org//next/master/next-20190215/arm/multi_v7_defconfig+CONFIG_SMP=n/gcc-7/lab-collabora/boot-am335x-boneblack.txt
>   HTML log:   https://storage.kernelci.org//next/master/next-20190215/arm/multi_v7_defconfig+CONFIG_SMP=n/gcc-7/lab-collabora/boot-am335x-boneblack.html
>   Result:     8dd037cc97d9 mm/shuffle: default enable all shuffling

Does
http://lkml.kernel.org/r/155033679702.1773410.13041474192173212653.stgit@dwillia2-desk3.amr.corp.intel.com
make any difference?
-- 
Michal Hocko
SUSE Labs

