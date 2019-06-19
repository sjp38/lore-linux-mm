Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09E88C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 07:54:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AACB420823
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 07:54:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AACB420823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 200866B0003; Wed, 19 Jun 2019 03:54:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B1778E0002; Wed, 19 Jun 2019 03:54:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 079EE8E0001; Wed, 19 Jun 2019 03:54:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C07CA6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 03:54:03 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y24so25013858edb.1
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 00:54:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=yNoD6UxAKWmxgNN4UdxnP06/9QNwmYpLYRMjVzofnEU=;
        b=PsDl55/gzJ+mELbO5GokmLvBAhFEiqDkSBwUFE7iaknCgJ/hq71rkmpFFe1nrcFEk7
         FYcJtQThthnzCfwfE0g3pLMmz7e8FGW4G/IgmxsoNWD13YNnux3RasLUYCwjyQlsSHoW
         PqyvxOtjabZTiOtgj2kQyTvITIMi2LWrV79fYQyu0lgLPP/T/PkLAD3tKtzsP1N4qNra
         nwVWRbHByugv8AycoKBe5KVHoBGyf3mockL1+hYvr1bidR/hUTnC4Vsrxy5+D9FbEu7b
         V882a4YxcBRxiWYoHFKdXyQ9eABl20OHctx5xeSIZQLEpB3pXrjBrex9Zilz6mA+/GwN
         ksXA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXjblzrCr1AyLLKm4ASasR9bdw5r8CA69KBU7GD6ueoDYlkPRg6
	T+5LWyBIO9F3H3PpvqHkrwrdfK9uAE+WoctMvvnVo0s5qraWqvVTDuZTXN1Xg332ShEfoprGtee
	4KCnLlSJBBu7hfJNNRX6o74CPwqkxsaCBHIuRqVxRT7lVSvMKkAzbGSaEbyD6favneg==
X-Received: by 2002:a50:a389:: with SMTP id s9mr131226909edb.113.1560930843251;
        Wed, 19 Jun 2019 00:54:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFHziQoBlk/i68LOe6UDDqI/L2/augQtX2npdW+dVVJ5NLkHOwwkoDtnXwkecy25lk+gLI
X-Received: by 2002:a50:a389:: with SMTP id s9mr131226858edb.113.1560930842381;
        Wed, 19 Jun 2019 00:54:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560930842; cv=none;
        d=google.com; s=arc-20160816;
        b=YZBr+a19mJg4l2SMZtng/avnxRUZg/DgLWAluCmP93nYip2OLFQ9Qg21QDoc6I3+Lv
         Vl4GCR/wLdeBCL7qQz52Lwg80EyDGuhHh24B9LtVp8uUyZs8kOrWHWnk2lAoGyOfpFNk
         SqBtlztnbrquETP0xPCJKVtnfjzWdOrFooKHwe+B217yQV0gNIihuyRmj9/DXVJpL17d
         g6XeDLG2F7JqHD/ZPfIOXs5ZcvcjsIXoKTnMkpazW+TjjyJ8mQJtH7+vBVR8ldn77L1c
         FUfan6v2Gqkh24P4v/1rYNmiTTgIPztR4Ap67XifiDfeMCrcLbBbKIc0ZZ8VfNjEAVgW
         pgqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=yNoD6UxAKWmxgNN4UdxnP06/9QNwmYpLYRMjVzofnEU=;
        b=o0SByBA9Nl9McejqTwW7oamy27/Bc+Uy+W+S6pDJeJX7EyH33phSnGGEnDU28dg72g
         CAEncVsLyJIT25NSmYGnOzx3qDoPMd5/cOiWTv2p54XvETEQpB/NxBBI2VzcRPfnFElX
         DEjR06Oi4KceSxN34Bop8Br77Gh27uHB324KIF/o/nYm2aZSYAZDGXSdRFLm7YNLhKD2
         E3h1nWAJ4MJmctCiUiazAzAOdddAfciEy9vZpMgCrmOVgBf6hNnoYcDqtyL/LH3wviAj
         tM0FXHw9awEXJ9wdsColHHA4nlopdyFQ1D0pbyS6dFYysmS/nsnQyPMj6MF1ZQF407rn
         eBYw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p4si10628553ejq.387.2019.06.19.00.54.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 00:54:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id ABA70AF51;
	Wed, 19 Jun 2019 07:54:01 +0000 (UTC)
Date: Wed, 19 Jun 2019 09:53:59 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richardw.yang@linux.intel.com>, linux-mm@kvack.org,
	akpm@linux-foundation.org, david@redhat.com,
	anshuman.khandual@arm.com
Subject: Re: [PATCH v2] mm/sparse: set section nid for hot-add memory
Message-ID: <20190619075347.GA22552@linux>
References: <20190618005537.18878-1-richardw.yang@linux.intel.com>
 <20190619062330.GB5717@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190619062330.GB5717@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 08:23:30AM +0200, Michal Hocko wrote:
> On Tue 18-06-19 08:55:37, Wei Yang wrote:
> > In case of NODE_NOT_IN_PAGE_FLAGS is set, we store section's node id in
> > section_to_node_table[]. While for hot-add memory, this is missed.
> > Without this information, page_to_nid() may not give the right node id.
> 
> Which would mean that NODE_NOT_IN_PAGE_FLAGS doesn't really work with
> the hotpluged memory, right? Any idea why nobody has noticed this
> so far? Is it because NODE_NOT_IN_PAGE_FLAGS is rare and essentially
> unused with the hotplug? page_to_nid providing an incorrect result
> sounds quite serious to me.

The thing is that for NODE_NOT_IN_PAGE_FLAGS to be enabled we need to run out of
space in page->flags to store zone, nid and section. 
Currently, even with the largest values (with pagetable level 5), that is not
possible on x86_64.
It is possible though, that somewhere in the future, when the values get larger
(e.g: we add more zones, NODE_SHIFT grows, or we need more space to store
the section) we finally run out of room for the flags though.

I am not sure about the other arches though, we probably should audit them
and see which ones can fall in there.

-- 
Oscar Salvador
SUSE L3

