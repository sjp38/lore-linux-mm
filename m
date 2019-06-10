Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 240A7C468D8
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 17:07:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E5D84207E0
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 17:07:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E5D84207E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7AE9B6B026E; Mon, 10 Jun 2019 13:07:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 785CD6B026F; Mon, 10 Jun 2019 13:07:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69BE86B0270; Mon, 10 Jun 2019 13:07:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 336356B026E
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 13:07:11 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y3so4841158edm.21
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 10:07:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YMvbynfPbKtyQZGEWhIKZlC4TkPvHd5zA5aW34VqlDQ=;
        b=VuXd7zO0H0a5n5AGk7+n+5auksi8HwCeTRBvPQL2tVtpM+H5X+F733AE2Yc6W2ZnIo
         lE26vSuEYnQ7XHCb+zAMGCYNfx47y2TygvgEla4b9kwHkigGav8tYO23tAR2uo0CMlOf
         I0lzc7Mp/vBy0JJ+UgLUyTwmOdMTc8qxjAZfxZCQUYJt2yx/HZipKFbpddW0DQf/1Cwe
         Gbks1Pg/8enqYtYzf7lYBwL0ZSzScIdnfATQo3gdMU32KRSjzW4d16wNnrkD9id8mJRU
         J7Z0h92HCr5WSX22g2syVMXEZ7cMCig+brGW+8YyJwZxpHKDIVQfzpA0SVMRzjksVdq3
         gEeg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVgDBe54pELrZOUGeI4epVkzbLKAMdPNXFDSogPiJKYvPRVwC2I
	qNY87m0oHonyJOjkUPWH5LSe/OBkZzbhxkRyPr4LDDh3VbAKFJADVpY8v5TSV+/BBx4JZL4Q4Ee
	nISNW+5ttIJAe+cVBKXMqcp/wtFu398kbyhJVuqmkwQDYkbAo/HtDyNqOyCNZRC4vZg==
X-Received: by 2002:a17:906:5855:: with SMTP id h21mr28264690ejs.15.1560186430692;
        Mon, 10 Jun 2019 10:07:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzdTUusa6GSEw74/z5Y0yQGNa90pcM8k4XpGjiWvibtRqW/WZUnP6hdeq1IvXjLeti/mxPL
X-Received: by 2002:a17:906:5855:: with SMTP id h21mr28264620ejs.15.1560186429922;
        Mon, 10 Jun 2019 10:07:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560186429; cv=none;
        d=google.com; s=arc-20160816;
        b=iEe+6xG+jFua8Yd577x9xHlAYq2x8B3iZBId3V3EbRSQ1fie0Vh+T2Ow624h+jm3kR
         TE+O/PKqgsfu+kO+vC60joEp2KaJXtHpc77ejEM+JUZ7a7jB0CM2ghRZo95MMkjNudsX
         HqwAFcKPMdKRfgquK4zBof/KVtfk5N3gr0+kQ4ZKCtos7Byfu1N6zDxGy2yIL5Y1CWZ0
         gdpKSMu7ko1OUfrGPu6e4Be5KCSxqi+epDeQ20fvnfRnJtBXaKw2kgpubvWtIN1cXKv2
         dYJuuZyzZwdZoOAEac0zGq5g5viIEpNDFRNdh7H5Cx7xehXmcfqqMffyQIg0WSGfBl+M
         JYag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YMvbynfPbKtyQZGEWhIKZlC4TkPvHd5zA5aW34VqlDQ=;
        b=pTFVcoGZ+/0riQKzzCQiV8yIhIxtKh6qNu5JsaVIxzHTV7lc2HJX6x5afbKQLtX1Es
         /0RQFXsOPqueWcau6vSiw+eY2251yADO0Iu2oBfuXnzq1Vity4XnuR7SGTlm3gyBeXH4
         1E+M/vZ8lq9fGy0GjgmX/UfEVjGjjewF6A7alm0FQpoX8p3SCtrFq94EklefELbHzSP7
         xl6PFEyKafTRDhMmmbsk6LTAeXc4aca0cRa97FCWG3YwnquD94poBI9/kcBXPcRMkfT/
         ZsPhPX+5kywDoOu1SP1ouO4LnCr90WIh9NZl1JYXK57Y3ztNv0AcDSbsF3PD6L/RUk9r
         sdTg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z31si4827846edz.165.2019.06.10.10.07.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 10:07:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 159A4AD1E;
	Mon, 10 Jun 2019 17:07:09 +0000 (UTC)
Date: Mon, 10 Jun 2019 19:07:06 +0200
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Oscar Salvador <osalvador@suse.com>
Subject: Re: [PATCH v3 02/11] s390x/mm: Fail when an altmap is used for
 arch_add_memory()
Message-ID: <20190610170705.GD5643@linux>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-3-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527111152.16324-3-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2019 at 01:11:43PM +0200, David Hildenbrand wrote:
> ZONE_DEVICE is not yet supported, fail if an altmap is passed, so we
> don't forget arch_add_memory()/arch_remove_memory() when unlocking
> support.
> 
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Vasily Gorbik <gor@linux.ibm.com>
> Cc: Oscar Salvador <osalvador@suse.com>
> Suggested-by: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3

