Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1E5CC04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 09:47:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95CD420843
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 09:47:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95CD420843
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2AEF6B0005; Wed, 15 May 2019 05:47:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DC266B0006; Wed, 15 May 2019 05:47:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A4426B0007; Wed, 15 May 2019 05:47:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3BC636B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 05:47:01 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x16so3014644edm.16
        for <linux-mm@kvack.org>; Wed, 15 May 2019 02:47:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=7lQzo/0aSz4p9swdxWY1v5JxCryfatuv+OqMq7FpKfk=;
        b=grMBq5fp0tkfPFkiDNrClBvE/CdoFbCxiWKeyM55eq3JegyzPwAWHrmV0gPx5AMZsr
         gDkGL7BNqk70wlZ/RASS757S8KDRHzMWJkAt5ONzvw5TNZmFVTY+ltgUHyT1ehGOVztC
         I+ze97e42bhiqXGiP4aRY9flzC196f/8yBo+BCADyhFg++xA6RJ3JyTXk1a53g66g3eC
         tt09HqtsVLmE6auMKsCP7a0OeHc7o226fxTwB7Hht85D6rl23pUH/2F0RJsyMF/NSpJY
         h0X/uWME1waNYs0e4bNcGAIDnPs5VJsSzw6bfcmx/bQ6A9P+vu7Saj9+Mi5P0NfByDC1
         UdFg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: APjAAAXZDjPBPgl2YWYDQ3clFUlImhgpR0r5VDUO32phmiLid6vaahw9
	BnUKESNONO0WHjU1FBVsXfkkbMGnjAKNrY12syPng8o9oLz54xCmnn/nMBTpcMQDHnuN+7+zZ4Z
	ixCEkfhtdph/h0JQtl7agKTBhLVOrEbWdYj5DKeJP/OFmsEpp0/+lOswg8+FL6gWuUQ==
X-Received: by 2002:a50:aeaf:: with SMTP id e44mr42020599edd.239.1557913620826;
        Wed, 15 May 2019 02:47:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFXfVJE4ZNDUYC1OOBbcPHhts4rDVYrH7e9O364k21ZMVTEx9R/dKAeiLP+avQmJKjuVvb
X-Received: by 2002:a50:aeaf:: with SMTP id e44mr42020535edd.239.1557913619902;
        Wed, 15 May 2019 02:46:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557913619; cv=none;
        d=google.com; s=arc-20160816;
        b=GaLNPK0U4XAZvLEylR6Qa6ou08Ipol/wYxYD86TtnzXeeSHMsBH1uqgGKtgYiGiqqG
         Cqwr7Qix54Cxc7/llXhsPqzM4PzoLy8XtI9raOyz0wu+naF07kx3GmJcGso7oG5emCcg
         W1JtgWWSCVliMmp+T9LdpE00Pq7sHrhjPeMA8euv2QLYRfRvR58JU7jfy5jn0WGChrYo
         QXrOjsvXlf5GuY5Jxbu/p/QF7MA/BVmnLw+r29wlroLd71uA/esinHu0gwQI5In0Uip3
         GWe2F+jRHbgzRDjZHDwzstC22tICUIadgBThQXFLDxAmHh+wg5oaR83bAdvavOp+l6JD
         lD2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=7lQzo/0aSz4p9swdxWY1v5JxCryfatuv+OqMq7FpKfk=;
        b=yQib1uaUF3kaPa7Yyb2yYcrJlStA0MntsfqBRnPMi6qMfurWN5h3E6kNmUT9gRN8X0
         6Y8V8OZDV5QO/5H5bW0ffUf66ZMlfZGWOqcduCx/fd+9ZhFngV+7VdcI7SHFK7OTAo+K
         QZym9nyfAiY3F6PvvQGliHZmUkbugUJx5Eq323HLVr5nIgKQjai9hF1R8j3uCE2DEtPy
         jPIbTIReQ7Y67EDN7Pn9PIMvZ4CYf3UpasmRchEZrTqfhILdQPNxNxAfsSupxzDNqPOY
         n8ffy+BiXZDCFSyBQJizXCGTEeFZmwm8cPRG0x8+lKfHVmYGSFbNCaQJDS0TzsZYDMEc
         vSiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id gk15si996409ejb.270.2019.05.15.02.46.59
        for <linux-mm@kvack.org>;
        Wed, 15 May 2019 02:46:59 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E815A80D;
	Wed, 15 May 2019 02:46:58 -0700 (PDT)
Received: from fuggles.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6E2513F778;
	Wed, 15 May 2019 02:46:57 -0700 (PDT)
Date: Wed, 15 May 2019 10:46:55 +0100
From: Will Deacon <will.deacon@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	Toshi Kani <toshi.kani@hpe.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH V4] mm/ioremap: Check virtual address alignment while
 creating huge mappings
Message-ID: <20190515094655.GB24357@fuggles.cambridge.arm.com>
References: <a893db51-c89a-b061-d308-2a3a1f6cc0eb@arm.com>
 <1557887716-17918-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1557887716-17918-1-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.11.1+86 (6f28e57d73f2) ()
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 15, 2019 at 08:05:16AM +0530, Anshuman Khandual wrote:
> Virtual address alignment is essential in ensuring correct clearing for all
> intermediate level pgtable entries and freeing associated pgtable pages. An
> unaligned address can end up randomly freeing pgtable page that potentially
> still contains valid mappings. Hence also check it's alignment along with
> existing phys_addr check.
> 
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> Cc: Toshi Kani <toshi.kani@hpe.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Chintan Pandya <cpandya@codeaurora.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> ---
> Changes in V4:
> 
> - Added similar check for ioremap_try_huge_p4d() as per Toshi Kani

Sorry to be a pain, but in future please can you just resend the entire
series as a v4 (after giving it a few days for any other comments to come
in) if you make an update? It's a bit fiddly tracking which replies to which
individual patches need to be picked up, although I'm sure this varies
between maintainers.

No need to do anything this time, but just a small ask for future patches.

Will

