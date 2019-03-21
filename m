Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98783C10F00
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 10:37:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F00D2190A
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 10:37:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F00D2190A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 03C196B000A; Thu, 21 Mar 2019 06:37:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F2F406B000C; Thu, 21 Mar 2019 06:37:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1D166B000D; Thu, 21 Mar 2019 06:37:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3F06B000A
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 06:37:02 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n12so2054553edo.5
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 03:37:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QhSmSIO6EYWF56DvokCYTYbiXi2ADK9Xknx0az/3VRQ=;
        b=ZPrg6Qs3w0Q1In9tXcqBfIqCLfSASCq+Q+PXw+WfxC0pI8zZrgxWKdDUy178zu+2Dz
         AEdl2+ca9CvRRT8tJf0nqtfU9fGmtru7O/5JcrHAxmvc/4/ooe19af2ciSBZtWl4F1ml
         Zpkl0iJuV9eM5Rlan/Bl8bceNZaV9XLu4yi83eVHIg4wEWAsybIyLFkuKHYGcr21d45h
         5+tMSVYkdnbEqUkXl5R+qc/GfEfZX4NzMJtLok/ppxkdxVT/3XMDylBnKet3CZU6HBFN
         GvCbkRrcrEDzzzrDPX3pAOmlfing3+jHr1k/2QzP+7a0r1PXQ0+QqGXdtXmfxDjdy1ir
         vRig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUhKoy4ItqJAtak3IDJZIw9iq4Xp8fEWGie/g2cAXo4YWsMSpY6
	awYJqvRZ1ojAe/65whn6pTrzJ4OZdaaGTFAc5us4Nb83g+jBxI/BBBxLTZGkkoCjPb3kuyzikrI
	XghKsVDkOP/7vuG3zwqbclNWOTOMtav4bj3ScPeM9O3yWy0fkBPyFo8utTmb86tfiHg==
X-Received: by 2002:a50:ca8d:: with SMTP id x13mr2022138edh.56.1553164622156;
        Thu, 21 Mar 2019 03:37:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfj0gVI+4LPSM+O+Rqxs7XTdNQivf6PE68aInmW0bPYncD8MdODvBqD7kGvTEu+lBR6R1O
X-Received: by 2002:a50:ca8d:: with SMTP id x13mr2022097edh.56.1553164621259;
        Thu, 21 Mar 2019 03:37:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553164621; cv=none;
        d=google.com; s=arc-20160816;
        b=HV7pA/521eXcaAjDa5QylXqlRYNTArliWKOuQjBYIgGhG9vy0Oa6yCxoDDzGmHGS56
         NQgmKl/JHT7R3cUFk/a3pfPf9FdLZawvHUMyI1JZJgmf5X47FrWrTvVESHAyBr0rsrDz
         YJ35xa1XAHgYaFYTes4MbeWun6+Zd/J4vSahcvmTR+AntSsniMoUTUBBr0pTzpl6K8jy
         cfF1c6c9RhViaUKRNcD42F2+UvtmByqR5Etag5Ydbr0b0buMZ0MIxcNN5Vt4rWcor+x3
         bNqG1yMS7DVxdBNN3jmcm1EuaDdRBXYpZsg6L2aODkp5PnLJ+is2+0Xo5a0+zdxCRs+C
         AZyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QhSmSIO6EYWF56DvokCYTYbiXi2ADK9Xknx0az/3VRQ=;
        b=aBL1Q4/2FKoDpt9Cr3S2Ff7xbBmXBqKBQT3SUE3O9N60Us1ZQws+WEhClUrHL31o1k
         oPYxd7Z9KVbcXp5/cY/mG3hA58orPO+q78Knpg576EjQefh03kdiVjwmWBrreb5LdM8s
         U9L+EK8J//jaxPOuWlEip5xwC2ZFIPKJaJjo8EiLwFiShWCe1XyZVeJBUru/6nIBKMFJ
         HZFVd/lX2u+PTbXvJjg03Go/js4oeWTLqKm1guVrjWcHWqgxPlG0aWUZRp2V6/rqk31W
         xGVCU/pcbEEErDYXsGCr3KdKSeN52ymZmUj01ODBOPBvPCfyRwQgSYD6NKRMpgK+gXly
         EnbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id c2si1536286edi.165.2019.03.21.03.37.01
        for <linux-mm@kvack.org>;
        Thu, 21 Mar 2019 03:37:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 9825D464D; Thu, 21 Mar 2019 11:37:00 +0100 (CET)
Date: Thu, 21 Mar 2019 11:37:00 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, logang@deltatee.com,
	hannes@cmpxchg.org, mhocko@suse.com, akpm@linux-foundation.org,
	richard.weiyang@gmail.com, rientjes@google.com,
	zi.yan@cs.rutgers.edu
Subject: Re: [RFC] mm/hotplug: Make get_nid_for_pfn() work with
 HAVE_ARCH_PFN_VALID
Message-ID: <20190321103657.22ivyuyq3k7zhy5n@d104.suse.de>
References: <1553155700-3414-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1553155700-3414-1-git-send-email-anshuman.khandual@arm.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 21, 2019 at 01:38:20PM +0530, Anshuman Khandual wrote:
> Memory hot remove uses get_nid_for_pfn() while tearing down linked sysfs
> entries between memory block and node. It first checks pfn validity with
> pfn_valid_within() before fetching nid. With CONFIG_HOLES_IN_ZONE config
> (arm64 has this enabled) pfn_valid_within() calls pfn_valid().
> 
> pfn_valid() is an arch implementation on arm64 (CONFIG_HAVE_ARCH_PFN_VALID)
> which scans all mapped memblock regions with memblock_is_map_memory(). This
> creates a problem in memory hot remove path which has already removed given
> memory range from memory block with memblock_[remove|free] before arriving
> at unregister_mem_sect_under_nodes().
> 
> During runtime memory hot remove get_nid_for_pfn() needs to validate that
> given pfn has a struct page mapping so that it can fetch required nid. This
> can be achieved just by looking into it's section mapping information. This
> adds a new helper pfn_section_valid() for this purpose. Its same as generic
> pfn_valid().
> 
> This maintains existing behaviour for deferred struct page init case.
> 
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>

I did not look really close to the patch, but I was dealing with
unregister_mem_sect_under_nodes() some time ago [1].

The thing is, I think we can just make it less complex.
Jonathan tried it out that patch on arm64 back then, and it worked correctly
for him, and it did for me too on x86_64.

I am not sure if I overlooked a corner case during the creation of the patch,
that could lead to problems.
But if not, we can get away with that, and we would not need to worry
about get_nid_for_pfn on hot-remove path.

I plan to revisit the patch in some days, but first I wanted to sort out
the vmemmap stuff, which I am preparing a new version of it.

[1] https://patchwork.kernel.org/patch/10700795/

-- 
Oscar Salvador
SUSE L3

