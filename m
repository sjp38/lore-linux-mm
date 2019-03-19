Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58B1DC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 11:57:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2133C2082F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 11:57:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2133C2082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A91FC6B0007; Tue, 19 Mar 2019 07:57:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3F5A6B0008; Tue, 19 Mar 2019 07:57:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92D8E6B000A; Tue, 19 Mar 2019 07:57:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4F4866B0007
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 07:57:54 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id l1so2406400wml.5
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 04:57:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=P0MZ6M0EfHNNEfzRyrmoTFirJxxH24YYaVG/VM1x2Ao=;
        b=FcAil7O6DDXzRLNkihgn+UwtH4GxzVPZYSVZRL2Yl7p6aHXVbjmoesI+Dq/jK6cfFb
         96AAuqTAOjbIv3119+8O7R45NidAFRgw9+Us0BRomVOAqK48lotucbk1sxLb06OhHr9M
         av6Xfpe5fqG+Vyqmj0PO9/N8+EIblM01pYpq4Oky3WOe+gF1GrT7K0QS63J5wX3OxIue
         HmA940uZPxDZjXbCmjdNlFGtuFlTV8YdkZmX30QDarP1wLRBrxtJgMa+v4lsA85cq3ah
         FOMhxmcqHkq4OubRgPzDDBURAalQh4SPGkejVmEy43xLZj5GzQdN3FRbY2gCfMpoj8eB
         lobQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAWKPfjoQv0kGztHPUrC0orzt+kMJuE8EksHrfLLtQq+8Qa1dqO9
	fxz1yHtM0pQjJetXyLj2O6JG6f4CMwN0zmqMiD6fP9sgyhGdSBchDCpUWbbzJ6MgeadgPQ6+vhL
	oeaQ7JmO9havd9BQOROhcZt/9D3RncHZO/T0MDMsLPHQP+4iH6xwPtV5MXCk5BX2b1w==
X-Received: by 2002:a5d:428b:: with SMTP id k11mr17437132wrq.17.1552996673849;
        Tue, 19 Mar 2019 04:57:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsaZeoeKoyon9H6lvkuVYCGAGOpky0meL6qSG3GWp2qNXUh4BCow5p+9Gb70dx/X2juKDy
X-Received: by 2002:a5d:428b:: with SMTP id k11mr17437067wrq.17.1552996672932;
        Tue, 19 Mar 2019 04:57:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552996672; cv=none;
        d=google.com; s=arc-20160816;
        b=guhc4TIjl9irqKYadg+FbBJztJRrGoXWjaz2FvirFtNcNL6IsoFdevwJwCYvroMWw9
         wJLIomRutK8Cd8Ta7UNjSg4bWiqtOql7kcVV+KoSDWalPTe3GPhkBG1M32QpfctZCEYD
         fOO74N9NTqqo0DsBHyiFKHHusmO9UQxaH/KmQtnm6GnroSRsaxX4FSUHmLQ/28sp8Tgt
         Zsojt/gl/uvh5hMk/jJwzLPxkvSu+Ea+FPeSDLLJAnWtn0YPBhjS9d1qtljXtl2ECXjB
         bOmcu5iDyLi8664zC9ZGjhgmzY9wibCMF3nsfXvtaBPvbDN3jcYQPj36DTOktDIEeZew
         XiKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=P0MZ6M0EfHNNEfzRyrmoTFirJxxH24YYaVG/VM1x2Ao=;
        b=aF2n/26Xt/G34vqt4hVCfXm5HBdSL6zeCGkA2+Cf7EUsM9omy3w9haPW8gQvlZC9Na
         4WEvwJ/anb0cHHrHZsy5A2CNJH/83TSyDjQNSf+u0OVU62uQ4ipMynFuRhiuFJ4M38fh
         mlQiDFUpphIDT32Pfr5zGOR0oRwOTTQ7mDMz98iNXvX5KsXadixpukGju4/q5+HVRETp
         x6Df3woA5mjHvcXe3RlT142iYie1uqsdRruZh1KVHX7LB347Xp1B1BpEIyDPP/7PY6MS
         NcfclrLvnzGT3Ja1AKShEwhf7zGOKhAU3c9jVGxwluAQyblQJl43Rr9rRbNLgDH/CjLN
         3jvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b16si8276812wrr.337.2019.03.19.04.57.52
        for <linux-mm@kvack.org>;
        Tue, 19 Mar 2019 04:57:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C1E1D1596;
	Tue, 19 Mar 2019 04:57:51 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 00CD03F614;
	Tue, 19 Mar 2019 04:57:49 -0700 (PDT)
Date: Tue, 19 Mar 2019 11:57:47 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, paulus@ozlabs.org, benh@kernel.crashing.org,
	mpe@ellerman.id.au, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kvm-ppc@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH v2] kmemleak: skip scanning holes in the .bss section
Message-ID: <20190319115747.GB59586@arrakis.emea.arm.com>
References: <20190313145717.46369-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190313145717.46369-1-cai@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Qian,

On Wed, Mar 13, 2019 at 10:57:17AM -0400, Qian Cai wrote:
> @@ -1531,7 +1547,14 @@ static void kmemleak_scan(void)
>  
>  	/* data/bss scanning */
>  	scan_large_block(_sdata, _edata);
> -	scan_large_block(__bss_start, __bss_stop);
> +
> +	if (bss_hole_start) {
> +		scan_large_block(__bss_start, bss_hole_start);
> +		scan_large_block(bss_hole_stop, __bss_stop);
> +	} else {
> +		scan_large_block(__bss_start, __bss_stop);
> +	}
> +
>  	scan_large_block(__start_ro_after_init, __end_ro_after_init);

I'm not a fan of this approach but I couldn't come up with anything
better. I was hoping we could check for PageReserved() in scan_block()
but on arm64 it ends up not scanning the .bss at all.

Until another user appears, I'm ok with this patch.

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

