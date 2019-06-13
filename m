Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB9DEC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 12:28:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84A0D21721
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 12:28:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84A0D21721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F0EC6B026C; Thu, 13 Jun 2019 08:28:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A1DC6B026D; Thu, 13 Jun 2019 08:28:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 06A2E6B026F; Thu, 13 Jun 2019 08:28:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id ADF126B026C
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 08:28:40 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y24so30685305edb.1
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:28:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=JmNM7gkvFldkGTmJO99C+BwqKX+y/M/lLJoJIjoYUDo=;
        b=Od6gNkB4O3YTyqgUcMYqshXy6B8Avo3hAQm8URMZKYT14Cq+coOy1GJMRUg9TrC9iZ
         YRyQKbZVSUwKpDsGmVmZmF3IEn/KISptvp8ql/EvGeAoR/ChDVwZHlZGGJN/fgyvS3JK
         gnAK1BCvuneI4qS0A6vH8BNrhYjxhwMnvSTpBe52XhZQG8RHIOIBgUHM7zcmWBme39bL
         nEHuh/IKiM29Q16VEUvgLROgRega6No1Hy7cIvYkZB8J/3N8nHavI9zQG0s0wTFoEX19
         huZsI5ajkDormDnQ6mb3rUAMYlQDl52LrPpYu8Ox9nDJUMe1U5+P6zMOQbLtfat8XC7d
         hP+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAW4ICY2zxeRu/UIX1+P209QDDhb1iyU7FWbi6Na9j/t3hfZrDu7
	TRN5rbL4Os0I0NT1LzJ/1/TAJrpzaeEwdm0pOvHiHHAdEb3TyOOqiVOCJSy22dxOkNVWAuNot53
	WvnIZ4eq4ubAjzYkbWuWaNDizkcS/lWRoY3DMixRiyn9TfZk67h3DdexMNZhea+BS1Q==
X-Received: by 2002:a17:906:7092:: with SMTP id b18mr12082032ejk.40.1560428920170;
        Thu, 13 Jun 2019 05:28:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+UTdL3k42Rv9Lpw8oOmkdR7zz1EqxRIxZOJYEVLUrCHoWJCLsF60ZrP71KNAuaXN7A70F
X-Received: by 2002:a17:906:7092:: with SMTP id b18mr12081991ejk.40.1560428919452;
        Thu, 13 Jun 2019 05:28:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560428919; cv=none;
        d=google.com; s=arc-20160816;
        b=T6gs/E/0OTiOT/bPrMBiNkoemWKPQuwji7JlZ2b4+chFHC5Mtorsj9j/Yl/o7xB6kV
         QiMe37e40IEuM6NXdnosTlSkOXFxGcmbSfRdLvMuJOWVRE+Zq/oYmaSQyBwuhgWfr8D3
         GvpwhU0rtXrx/3vUzc1mTpyOYTYbqUWK2BnuW/dioVVAeTp6rsYjHoi/ma5N8eT4Id8e
         0LNcbCNNT2cu+KcV/L++Z6HFxc3ZZ185W2Kx+0gPkCvvGWJObIcYFl79jU3kmcfgqFzX
         /SCfq6VCivkTBulL+gw1EHHMTiK7DMge6DtJyvDasIIxdef4bSUwa5ZcafdJj+Fjgo+h
         7RBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=JmNM7gkvFldkGTmJO99C+BwqKX+y/M/lLJoJIjoYUDo=;
        b=Iu66mXVQ3fof1MggEaKS6ZFZToVqOx08Ktng4iboG4SHh+eIPkAM2PfbN88tNAc3ir
         54FBRdi9Q9LAOolhOIa4RfVdzNFfHE1aoZxyisvzQno0t8Cy6F9Y/FdmVXbnuAtvsSRL
         Sm5gpKQLKU5oVlQ+k7g2FVfaxQlaeSS2LpC/VIHxJl0H1KusWeioMba/MJ+D0mzJ7Lmr
         iyWWujcKUbMlqfcb7R0NlvAHmN5EBLvR0MsOAD+MOaAkYVFzPmTBkp04F49+Z1FV8RJJ
         UKOQh0RbeMriYqeV/t1A/Mj+npOjw7tj554lOKJX/v07/w6oGa73O0BG1iNavd0PzWrF
         Rv7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id v12si710652ejh.154.2019.06.13.05.28.39
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 05:28:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A1E6A2B;
	Thu, 13 Jun 2019 05:28:38 -0700 (PDT)
Received: from C02TF0J2HF1T.local (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C3B393F694;
	Thu, 13 Jun 2019 05:28:32 -0700 (PDT)
Date: Thu, 13 Jun 2019 13:28:21 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Dave Martin <Dave.Martin@arm.com>
Cc: Vincenzo Frascino <vincenzo.frascino@arm.com>,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	Szabolcs Nagy <szabolcs.nagy@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-kselftest@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH v4 1/2] arm64: Define
 Documentation/arm64/tagged-address-abi.txt
Message-ID: <20190613122821.GS28951@C02TF0J2HF1T.local>
References: <cover.1560339705.git.andreyknvl@google.com>
 <20190612142111.28161-1-vincenzo.frascino@arm.com>
 <20190612142111.28161-2-vincenzo.frascino@arm.com>
 <20190612153538.GL28951@C02TF0J2HF1T.local>
 <141c740a-94c2-2243-b6d1-b44ffee43791@arm.com>
 <20190613113731.GY28398@e103592.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613113731.GY28398@e103592.cambridge.arm.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 12:37:32PM +0100, Dave P Martin wrote:
> On Thu, Jun 13, 2019 at 11:15:34AM +0100, Vincenzo Frascino wrote:
> > On 12/06/2019 16:35, Catalin Marinas wrote:
> > > On Wed, Jun 12, 2019 at 03:21:10PM +0100, Vincenzo Frascino wrote:
> > >> +  - PR_GET_TAGGED_ADDR_CTRL: can be used to check the status of the Tagged
> > >> +                             Address ABI.
[...]
> Is there a canonical way to detect whether this whole API/ABI is
> available?  (i.e., try to call this prctl / check for an HWCAP bit,
> etc.)

The canonical way is a prctl() call. HWCAP doesn't make sense since it's
not a hardware feature. If you really want a different way of detecting
this (which I don't think it's worth), we can reinstate the AT_FLAGS
bit.

-- 
Catalin

