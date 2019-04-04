Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C05F5C10F0E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 15:19:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8602A2147C
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 15:19:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8602A2147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 096D26B0010; Thu,  4 Apr 2019 11:19:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 047CF6B0266; Thu,  4 Apr 2019 11:19:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA03B6B0269; Thu,  4 Apr 2019 11:19:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B53C56B0010
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 11:19:27 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p90so1607335edp.11
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 08:19:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=eP/pOczulQ965yyb7igfPO2dHeuTxmiNDDMd/7iFvaQ=;
        b=klj8fG5OfRWXH/TPFUA7BhO+sP5qaYUoKCLfNgdg/9NljdKaS8/ZrmR9mkskbQ+tls
         A5WqEHbKH4aJB3QrUSygGk7GcUysSwfLoG114Ok+cIvF2OQn0WF7vaH3Q5PlwaGEowfM
         Z1IygO6IAwBeJ3MYajzMPG63VFkAolTi3tHbzXJSHyRXzETWgdq+n+KsrxKK1AU1dxnz
         J4lYNo0XTdXulJ593o7HmvutxQjQsx5nhzYHpxXk5iTdaeOmUCSbyNNL4qsuyoSRCVYL
         ekbpxpIRkzSj5/Sf1IKQbbtPfuMvpGLvU0CxZuVnAHFOivG01RRzRaQC8GPIaK+URkOA
         sgJQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWHGYKJoqLWxePizTuejazCHzpOH0HY4fGKj38HAx6NlpKXlWDZ
	vIEK8lIQpkoh7IjhrKTZ7K9u3X/AXF+bYubaUDeu5szZL7RlvkklLwi3hY7hK2ud0Of3bO8aaji
	cM89vHezwACvJWzYxTjXjBe9MN6M/rtX5cUSZ2fNsKKUFCkJoW7wbesz3jNVYbBY=
X-Received: by 2002:a50:a4aa:: with SMTP id w39mr4295781edb.206.1554391167314;
        Thu, 04 Apr 2019 08:19:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw+ciluGtE3e8WdfrqtzJk+ItJEAhSW4j3aKMq6NyVTmqr1Goh6uk+Q2h5H07e9EDv8O6I8
X-Received: by 2002:a50:a4aa:: with SMTP id w39mr4295727edb.206.1554391166410;
        Thu, 04 Apr 2019 08:19:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554391166; cv=none;
        d=google.com; s=arc-20160816;
        b=iDP2EiZGP8jwqfFuyfpHS5xmaacyzzhWK5eV4k5xmm/J22qnouWCTgJsrEOpSJDtZ0
         PHCVqCvKsm56PfvW5NWLniDZuY2tVgdAJq0tEpHo9rIyu8tK3ecbKwHN9xcjIRwJ48TO
         T7PrwAFWUb9X0cSlCauCGb2UDQxDcVgrguWomkL3SdR5ACSRLfqHGt1gMCzmzGArtct1
         ux4E+0dy4flAnMXkPJh5yOFwAM5/s37TTzF6E7kniwFJV8aPSvwrpqDDCcZmflikwMNc
         J3FXW4nb8opBpdtzdIlTO2gf5ydePpjLg7GZiQ+4SGLv24/MXckyE+JdoLbSPdFIeyhc
         JtdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=eP/pOczulQ965yyb7igfPO2dHeuTxmiNDDMd/7iFvaQ=;
        b=X87huoXa4XNOkbpaCBNj1VayzTDG7DWqJeehnNlw9AV0IjozrZIjjmCb5WI7Gwus7Z
         P5pJGG8DDQTn8MQVS98Zl2pcB0QAKgsmrWoFrPbFppzJPZTsH15Ax0SdGOhmAP/hgcgA
         oNZEJ0otlKMAcwXNkdIjhyoy6K2oXH6ZgRDW6E5o7OIDItUnkU25bIXx/Y89Fz465rnT
         X8tR/z9nixAD/kedQh/ze8hSUVuSKhcdUrujNUvDVJrgeo1dJURXUgwZzf7RqgBG2tr0
         RCh9AI2iMU/ykLCII19HkLRE/HCqD9v8IlrbL26ny5fNr+95RmMXUjXU4v5Tzq7IwZgL
         k0AQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id j22si33842ejm.289.2019.04.04.08.19.26
        for <linux-mm@kvack.org>;
        Thu, 04 Apr 2019 08:19:26 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id CB30D481E; Thu,  4 Apr 2019 17:19:25 +0200 (CEST)
Date: Thu, 4 Apr 2019 17:19:25 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Robin Murphy <robin.murphy@arm.com>, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, will.deacon@arm.com,
	catalin.marinas@arm.com, mhocko@suse.com,
	mgorman@techsingularity.net, james.morse@arm.com,
	mark.rutland@arm.com, cpandya@codeaurora.org, arunks@codeaurora.org,
	dan.j.williams@intel.com, logang@deltatee.com,
	pasha.tatashin@oracle.com, david@redhat.com, cai@lca.pw,
	Steven Price <steven.price@arm.com>
Subject: Re: [PATCH 2/6] arm64/mm: Enable memory hot remove
Message-ID: <20190404151923.2zmf25wnwevb3dlh@d104.suse.de>
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-3-git-send-email-anshuman.khandual@arm.com>
 <ed4ceac4-b92c-47f4-33b0-ed1d0833b40d@arm.com>
 <55278a57-39bc-be27-5999-81d0da37b746@arm.com>
 <20190404115815.gzk3sgg34eofyxfv@d104.suse.de>
 <0c2b5096-a6df-b4ac-ac3b-3fec274837d3@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0c2b5096-a6df-b4ac-ac3b-3fec274837d3@arm.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 04, 2019 at 06:33:09PM +0530, Anshuman Khandual wrote:
> Sure. Will remove them from the proposed functions next time around.

Just need to make sure that the function is not calling directly or indirectly
another __meminit function, then it is safe to remove it.

E.g: 

sparse_add_one_section() is wrapped around CONFIG_MEMORY_HOTPLUG, but the
__meminit must stay because it calls sparse_index_init(),
sparse_init_one_section() and sparse_mem_map_populate(), all three marked as
__meminit because they are also used out of hotplug scope, during early boot.

-- 
Oscar Salvador
SUSE L3

