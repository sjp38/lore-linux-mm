Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A6FCC10F12
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 11:30:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23ED120848
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 11:30:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23ED120848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8CE76B0003; Mon, 15 Apr 2019 07:30:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3C706B0006; Mon, 15 Apr 2019 07:30:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 952376B0007; Mon, 15 Apr 2019 07:30:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 60B0B6B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 07:30:41 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p90so8743721edp.11
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 04:30:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=+Nu3cPsmgmF2G9QWQ4f15a/FreIKjO/mX5hxKaJs6Q4=;
        b=UdYO8kQ1LsyayJ73dHOsHAoznzcniSpAl50yM0xFfxNJi4sXVgwZ3T7MemEb6g8qxu
         WDm/0n4xUZGcrbbQN61jbb+T9KmcWe8vsOKvK+s9thtJlBPMUcfBZs4EHCsNeT1JbO46
         bP98gjuia8c4cXLRtS2hRxfq9DLwgbvOcYbZnKr0vVReSvF4dOmYnzBnDgniOilfjxLY
         4w66yx/vjHRY91z1/AgSvul+xG2PYcf/hk+tTSbBR+4g5C9NUXcq/Uo2gf8UXlzN3gcU
         AzCHSsa4wlzZAECSDiIrk9OP5FQ1wedcZrAmg5LxSrbeejipagXomsBxx9LWiD/n2t8X
         BtfQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXxsXlt/7aOGAhfou0soq0N4e7Pjuxlw7eEl82jX/HEyLmvFGeh
	bzhvc2mdeyjrCUyAYSH7g2k+u0jupAKi/bPWITwQrBCbUKbwMIuHnsVMSDFrwb+2rMFTLFkb22s
	ffVNzZbsFwOiDDz4cF6gR/pF3zXeK1xxtEYxvShk4rH6eH6jLU2Nq9WyCxHTWbtmVDA==
X-Received: by 2002:aa7:d0d3:: with SMTP id u19mr47169429edo.234.1555327840963;
        Mon, 15 Apr 2019 04:30:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzo6hTerE/t8IaXu7C+fgvDrc/kBzPNeCZD8QeC7NzeLT3smU/1BouFz7yoGNBS4LM61i/c
X-Received: by 2002:aa7:d0d3:: with SMTP id u19mr47169387edo.234.1555327840211;
        Mon, 15 Apr 2019 04:30:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555327840; cv=none;
        d=google.com; s=arc-20160816;
        b=cQHcysQ6uAHH7pfG5p1d9BCiaZxwgC9S1WlN5AOwIhcdVAjqo/tvhE10C4L4xzgStf
         M1GrCGIzI+CrnKEShCkSuoklQ/bklvJ0VbYmsgLnkbSSoiClIr4yfqNBdLS+r/2eVv/q
         jqQpFd8tS43ZZ7ZP4Cu3s6VkkSzRqaABRvLZfrWknqb2dpwc3fPz04xldD5LNlnxQ3Cl
         miIqRjzNcsfhCSAbYXZKlvrkY0yDdXD081eU807yWr9V2Tytw6U9WG5k5+k41gXIvE8f
         I9XBaIJuA3suyp6+SgFKKPP6azuENYsNieU6YMyvfRVlhnFmBgYIuhH8cw6JiF/EGqKh
         XXgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=+Nu3cPsmgmF2G9QWQ4f15a/FreIKjO/mX5hxKaJs6Q4=;
        b=fg8bC1/8cd03vOpK7vYOGvV55+DM4rJyt5izUj7FAGZv0VePr9lZf8KrObNO6ubdFA
         dUGhY/R2HI9qq0/neiL+7sEbCPfPErQP9l84bCaGJZwI2kf76DwFihDtJ0836I6Yw/S7
         4PtCUKz612LsF67ddoARHAiUJFWaBLkftC2EJmxtiXJ8zMh1KlzRAm1Yp68XRdfPOY7+
         xs9o9zzZAF3o72cHpUCSMqp6/x8jJg0/rS+RQA+ump406HLMpBoVQyFf7Aib2bqLSlYU
         Y+7lXpHMa+qGAV81U2tIG45gMKynaalFtRyc5uM38ykP9Wh/nANY7Tp9Ucg16MZ+nvC9
         mGMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id oq12si2218650ejb.130.2019.04.15.04.30.39
        for <linux-mm@kvack.org>;
        Mon, 15 Apr 2019 04:30:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2C68A80D;
	Mon, 15 Apr 2019 04:30:39 -0700 (PDT)
Received: from [10.162.43.203] (unknown [10.162.43.203])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2795C3F706;
	Mon, 15 Apr 2019 04:30:35 -0700 (PDT)
Subject: Re: [PATCH RESEND 3/3] mm: introduce ARCH_HAS_PTE_DEVMAP
To: Robin Murphy <robin.murphy@arm.com>, linux-mm@kvack.org
Cc: dan.j.williams@intel.com, ira.weiny@intel.com, jglisse@redhat.com,
 oohall@gmail.com, x86@kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-kernel@vger.kernel.org
References: <cover.1555093412.git.robin.murphy@arm.com>
 <25525e4dab6ebc49e233f21f7c29821223431647.1555093412.git.robin.murphy@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <cc96cad8-2078-8ee0-9ce7-d073dcc702c8@arm.com>
Date: Mon, 15 Apr 2019 17:00:35 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <25525e4dab6ebc49e233f21f7c29821223431647.1555093412.git.robin.murphy@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/13/2019 12:31 AM, Robin Murphy wrote:
> ARCH_HAS_ZONE_DEVICE is somewhat meaningless in itself, and combined
> with the long-out-of-date comment can lead to the impression than an
> architecture may just enable it (since __add_pages() now "comprehends
> device memory" for itself) and expect things to work.
> 
> In practice, however, ZONE_DEVICE users have little chance of
> functioning correctly without __HAVE_ARCH_PTE_DEVMAP, so let's clean
> that up the same way as ARCH_HAS_PTE_SPECIAL and make it the proper
> dependency so the real situation is clearer.
> 
> Signed-off-by: Robin Murphy <robin.murphy@arm.com>

Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>

