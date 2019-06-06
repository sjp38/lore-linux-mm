Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48D8DC28EB3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 17:34:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D42A2083D
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 17:34:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D42A2083D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89AC76B027A; Thu,  6 Jun 2019 13:34:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84CA96B027C; Thu,  6 Jun 2019 13:34:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 761E26B027D; Thu,  6 Jun 2019 13:34:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 276D46B027A
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 13:34:26 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l53so4743381edc.7
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 10:34:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=cTbjYsgfPkBw+OSP89oA34euB64GQm4IFp6zD1ZV1KE=;
        b=KBCTFs0EAKzIbHzcOynQSsaLr83hDJkpY0F3HTZG1IlH4Db+b2n8KeR2iK02ddPfed
         8g5Y23JJ3MW6O2WyhB2TR+bpYGgPkpXYZiaC8EtMAVHe0b0G1zywCn5WEY4F9MRjOSV3
         g7X1BApA3/hv4/oS/j168wDcXZ88zbNdsG9DSbaGCePlEm/DSmjwwE99nZR2+nbhalDr
         lgjS0bEIO5GQiNhHslm31zwLOK7wA0RC9sGIXSJ6arI3EW14uPBmc/QThiEAAJmHnsOG
         l+psFWlUfEHHNTkskswtCNODG9ISqtibx+esf2D+xOQrS+N3FTGwjvp/RCEJrmbJzzKp
         1UtQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVkO4iOPAaHHsJ9aTbasT8FLSy0BuWPKpBckSBfGRGVFNba+l3+
	25wQf9+/6XVPYpadRMR7waBDCNkZnkDEM3QA7XatH00LYrAsHeKxUwbVokrTyVWRe+QSQp8jjvi
	OtXNEtiqy7Bf3e2IAaecqa/9yuv6i5XNtTPIsH+y9CeijhMJP7661Vk4OJEgYr7PqrQ==
X-Received: by 2002:a50:95ed:: with SMTP id x42mr7561925eda.279.1559842465738;
        Thu, 06 Jun 2019 10:34:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypZwZfjPOY/Ocu3oTzUnrNDMI8OlTQ3HULTiQAbtPckDaTzSyT6bo5/89EGOcE3vrpRe6c
X-Received: by 2002:a50:95ed:: with SMTP id x42mr7561862eda.279.1559842464989;
        Thu, 06 Jun 2019 10:34:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559842464; cv=none;
        d=google.com; s=arc-20160816;
        b=wqbVMBtOYW9gHKVOSM6hPLBfXEdZkrZuPkgm8iUooNyvvgQ1mEG2QZYZumNrl45+zI
         HHZFxFB5j8Db+3Et1q3983A05mGxWkiRnF/Bpr2gCxQW6uA2BDkxGmND155YwbhXJ3jT
         o4HOhCBwGVrDmbwraJvAtapuDRbi6h4aUoSGm6/AUj8ABoQhUs5jPsgoj0IcJ3xvX+wI
         OsMCFP8RzCpmVem0vSXL/888yJNYcL9easGHoFGX9SXbML72LkM4mYtw/ieS8W1aoMoO
         pZend96ebadRvjmCt3CPTRfGnmnnqRAcI9haLMORyl26ajlI6eagRrRMb62QiQqgWscz
         Mt4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=cTbjYsgfPkBw+OSP89oA34euB64GQm4IFp6zD1ZV1KE=;
        b=sWqwwwVS9N/S29uKFa8jf6s1+xeXrJ7xnehW6oY/pgq9SrNYR26hKQVS3dsB4eta57
         Sa3vmCznv5+T/8TlkU2QspGIoYhxqjc64J4nhuhZL2ajW8dZUrA4lDRsDcuSRrMnY4Ti
         9a2Wb+7f0XoQwBvWqUSyb+HxaReXHOckaJ/gH9fLBTpIy753F8vLP8l3Ke/qB1T+qXxH
         vH8kjGliq9arac/TEZ2FoANncP3A3QJbyzE/56JC8ajR70KJS/plKqAB9ezUQlPKrV6Q
         E7VsIC5YmfBAispvJWbjB7T7NPNT9My++nV6ObAKiAUnHEJCrDV7nrnBNoqGAdu02MlN
         WHrw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g17si1930207ejj.292.2019.06.06.10.34.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 10:34:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5384EAE4D;
	Thu,  6 Jun 2019 17:34:24 +0000 (UTC)
Date: Thu, 6 Jun 2019 19:34:21 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Logan Gunthorpe <logang@deltatee.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org,
	linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v9 01/12] mm/sparsemem: Introduce struct mem_section_usage
Message-ID: <20190606173421.GD31194@linux>
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155977187407.2443951.16503493275720588454.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155977187407.2443951.16503493275720588454.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 05, 2019 at 02:57:54PM -0700, Dan Williams wrote:
> Towards enabling memory hotplug to track partial population of a
> section, introduce 'struct mem_section_usage'.
> 
> A pointer to a 'struct mem_section_usage' instance replaces the existing
> pointer to a 'pageblock_flags' bitmap. Effectively it adds one more
> 'unsigned long' beyond the 'pageblock_flags' (usemap) allocation to
> house a new 'subsection_map' bitmap.  The new bitmap enables the memory
> hot{plug,remove} implementation to act on incremental sub-divisions of a
> section.
> 
> The default SUBSECTION_SHIFT is chosen to keep the 'subsection_map' no
> larger than a single 'unsigned long' on the major architectures.
> Alternatively an architecture can define ARCH_SUBSECTION_SHIFT to
> override the default PMD_SHIFT. Note that PowerPC needs to use
> ARCH_SUBSECTION_SHIFT to workaround PMD_SHIFT being a non-constant
> expression on PowerPC.
> 
> The primary motivation for this functionality is to support platforms
> that mix "System RAM" and "Persistent Memory" within a single section,
> or multiple PMEM ranges with different mapping lifetimes within a single
> section. The section restriction for hotplug has caused an ongoing saga
> of hacks and bugs for devm_memremap_pages() users.
> 
> Beyond the fixups to teach existing paths how to retrieve the 'usemap'
> from a section, and updates to usemap allocation path, there are no
> expected behavior changes.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3

