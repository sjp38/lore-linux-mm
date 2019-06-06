Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 973D1C28EB4
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 17:02:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69B7020693
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 17:02:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69B7020693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 027896B027D; Thu,  6 Jun 2019 13:02:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF3696B027E; Thu,  6 Jun 2019 13:02:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DBA8A6B027F; Thu,  6 Jun 2019 13:02:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9D70E6B027D
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 13:02:44 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d27so4615420eda.9
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 10:02:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=DrPMSDJ9GctNXFYDOwxTZlKQ8HNcUk73mNu2VAHmVj8=;
        b=S7tDwtSJJTsMDDliPw8gZJAnMERBHY3bUUBQP3dkbcYrAm/RQFsS9Vgf5XWLjZrOru
         2XRnCGZ8hKFG5zersDtyu+ovft/So8F61v7O9Sm10y0zTbGc3fXpYj3DVzEFxiCt3vSN
         LbIyGrAXpCzu/QPUG+GFW94v2xmbphEX52Uns4+mr1YrRurv0WP8Ba6PthFemT5Rr0Dt
         wnldLXvTiz3NHmrbuMqKbZtBCaNtACatu3H35V2zNRlpczyQL+1YDLEPq6ZnOX9kVcax
         RVmoSIJNvCgO1E+17i/q33BDxqrl4wXTSYdbtMEVOtiCCBZBISexKBWAGwk6eCTzdGoj
         NShg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXW7qPLsi3txblOWwBngtoIrWodXuS50BQ/UV/lhe609+Rlzw6q
	oexbqCj1teNLVGFQr0Tq0nK4gcBkoUNM7FGpgjR5dFh2j0nzwpepYiLRZ7VsnjInOh8YCOXU8pB
	7m5L+gF8vWBsGFwGFwYfeDztRko8Yx0hu5wn4qAv85AmuKrQ3YjUeFSSb0j8oEKoPEA==
X-Received: by 2002:a17:906:5007:: with SMTP id s7mr2884070ejj.81.1559840564023;
        Thu, 06 Jun 2019 10:02:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTimHAWuqx7skOpNVdIMEwOS13FWBR/IPJCnCSipqnMyQNuVXLKBnPSoEt1xPSxHWanIr2
X-Received: by 2002:a17:906:5007:: with SMTP id s7mr2884002ejj.81.1559840563334;
        Thu, 06 Jun 2019 10:02:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559840563; cv=none;
        d=google.com; s=arc-20160816;
        b=Wwe96DNu1aCJcwYJ5uUNlNBO0empmcKE4T23ubOFUrgEuHBmwFJdcQtVfD/b1J15s0
         BF0srUhK+S88v1W6oxcX27Kzwokhd5k3FwrfTArcozzvtOT5ALB9SOZgR6DuGBwPXOAo
         C/BOSN8OLhG9A+TbtPNnPQQkwmloGdop3Tqr08WOaqQEyn1TxnkMV9zpn1SMH9VGxSHU
         MG3a62PNeM3q6s+VfS7Qo7NJu68DoRNiAdc7rMzmmBL5UAk3BVQ3o/JgQg6yFjNMzwda
         ydRXx2oY0veFliJ+MpcdBvl8aBdmPH4l+YMkol5TWCf5GPr+ORKl9Syk7K6EX/Fz9iYc
         pbBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=DrPMSDJ9GctNXFYDOwxTZlKQ8HNcUk73mNu2VAHmVj8=;
        b=mVtPPQG5cqkLdgANzHLeVwh3bjAKkE7a4IY2t197AQkQIuOvCxdIaWBVyJQ0O6dtkb
         1dKUT3DNRTtposTLNSsgK77n1H1LbV0gx1JKNX13kLM2ciL/D0JpFibVCKQ1dZOH1Goz
         j8jBQMZsbfJuYVFX3/7zl0/4Dwaa6ldZdwDtAHC02/sqKOFm6WV6uX5MtJ/K4AczEeTS
         B4ozs6+sYeCi67Vdy5etUXkqLTnAA+Yluw8LEH3cvjjCu/GsPxZYBp9K/cRhJLzhsmzL
         ktOjwagnunusovtIkLFiHt36qVPXJ+9xpJmKduIgeDBr2JqSvmg0jk1TpE+iW9hCXxou
         Bn/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i22si572531edx.122.2019.06.06.10.02.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 10:02:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 853E7AD1D;
	Thu,  6 Jun 2019 17:02:42 +0000 (UTC)
Date: Thu, 6 Jun 2019 19:02:39 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>,
	David Hildenbrand <david@redhat.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>, linux-mm@kvack.org,
	linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v9 04/12] mm/sparsemem: Convert kmalloc_section_memmap()
 to populate_section_memmap()
Message-ID: <20190606170239.GB31194@linux>
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155977189139.2443951.460884430946346998.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155977189139.2443951.460884430946346998.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 05, 2019 at 02:58:21PM -0700, Dan Williams wrote:
> Allow sub-section sized ranges to be added to the memmap.
> populate_section_memmap() takes an explict pfn range rather than
> assuming a full section, and those parameters are plumbed all the way
> through to vmmemap_populate(). There should be no sub-section usage in
> current deployments. New warnings are added to clarify which memmap
> allocation paths are sub-section capable.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3

