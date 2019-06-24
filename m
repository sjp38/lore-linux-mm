Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 795FFC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 17:58:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 424A620657
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 17:58:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 424A620657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C68376B0005; Mon, 24 Jun 2019 13:57:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C18848E0003; Mon, 24 Jun 2019 13:57:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B2DE88E0002; Mon, 24 Jun 2019 13:57:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 65F106B0005
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 13:57:59 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d27so21540463eda.9
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:57:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KrwsAkcAw2v3F1L6aY+XSF75B2iEkM4vSjjVnem0/xw=;
        b=iXDsveyFR5ALUQIAYjzbG0uWnp+V3DKUTGZk4CkWQHEjOGA2Tqz5zMF9xTCsuyvdOM
         5/FrCV6E9DXAmobuGoSAxF76Z/q9Zxw09RjInE1f7c+zoxkoHydf8POJizKhiMGMF66D
         Q2Yo2a5xNzF6py6TY/s/ggJ4BU/HCtVmAa3bZMJriAinxndbPT07+AIAh3uEBML5FwvE
         pCk1s4H64afqJUtM6vqWqoSbHC3Em3TPm+X78qGG9zZ5jFcy5fsItzzZiINiq7X+a2Ag
         CgpNETS2ZEeeTi6/06XNBFjsDaPI+UAuQWUnGI60FqomHRArP00H7VWFOzVK7NitAmZL
         rGSw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWAcP1znnHMkdfTDIGrrA44FOFYvDb2fIbm6QVRX3YnBpVdIR7u
	uY0WbqhltKYpPPN6bHkMe0LslsRhtsZgOqbqayDmyRUHJcvWJnqpqGbkHnXiDumi7ZJfP4mCJPy
	4gKp+gmjEDK+bm/yhToCvtJLtTTHrr+4SDramwOAfCxHteK/Jgo0pfeoUZ/ogxyljzA==
X-Received: by 2002:aa7:c98c:: with SMTP id c12mr100994667edt.225.1561399078998;
        Mon, 24 Jun 2019 10:57:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcmuch3tlsLFqE/425evs9bMUbQp2xpnaCrJVmMdvT1Xp7WFhOZ9vbjqL/eV2ohm1ERZrt
X-Received: by 2002:aa7:c98c:: with SMTP id c12mr100994618edt.225.1561399078322;
        Mon, 24 Jun 2019 10:57:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561399078; cv=none;
        d=google.com; s=arc-20160816;
        b=oATnMAfeER4wt6zKdbUet+i/bFFNf/nvPkzR7BoyA9a5fygRB6rJO5y2OcN+Ec7dmw
         +JRDVaN5SGvr3egPrGylbm34gXPJ8S01tOemcU/S7Lok0dCFCH1MNtrgLzWOUwUYz9Lm
         6qDSRFEksAd46z0tqmqDkFqJmr+XRqb5XkV0rDXPA5xksauKI5Wmy9bh3fhKHCyhUy3Z
         r0aBqYFkzvhzKWrQdu1WagqpyZ4PFtxhDDWrbOqZVqY5JJL2jxlraaIv4TuboKBmXbYc
         Px0wvDRlA4K/2inszjjhkQsHiFLx6zdGI0P/1hz+N2oM7BodMX9oovYuI79tJND/gifC
         0Y7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=KrwsAkcAw2v3F1L6aY+XSF75B2iEkM4vSjjVnem0/xw=;
        b=BiRGwn6MyrUXdqMcn3Qepd9e93dQjP0PNvIR6Pznx479QzzqY3kIOfXUszWy4wMz9O
         tQ+mYuSX93ycxNW2NFo3UWClykcLle2NXsIX5QShBcXQBH+oIAe1wiy6avfLxsKvIsTQ
         ooUuX2T9JzIf1GS+udne/dLfxjMW93qRuluw4/ugvsr4lvQ1y8QTU1PE+K6gnDq7ozuc
         Bb2PRz2FdNIhzUs4750OyzTc9LDr1nAOrKVCWAx8ZYznSP40UhjVGmDao5BAr9vZsbMZ
         gi/Muiu9yq2HbX46nkWwS5gScTnD2PIuShjvRYWDh1lJv/fmwVYsobvBZ0nIItCs6ve0
         ENxA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b24si9520978ede.402.2019.06.24.10.57.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 10:57:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 83F67ABE1;
	Mon, 24 Jun 2019 17:57:57 +0000 (UTC)
Message-ID: <1561399075.3073.6.camel@suse.de>
Subject: Re: [PATCH v10 03/13] mm/sparsemem: Add helpers track active
 portions of a section at boot
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Logan
 Gunthorpe <logang@deltatee.com>, Pavel Tatashin
 <pasha.tatashin@soleen.com>, Qian Cai <cai@lca.pw>,  Jane Chu
 <jane.chu@oracle.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, 
 linux-kernel@vger.kernel.org
Date: Mon, 24 Jun 2019 19:57:55 +0200
In-Reply-To: <156092350874.979959.18185938451405518285.stgit@dwillia2-desk3.amr.corp.intel.com>
References: 
	<156092349300.979959.17603710711957735135.stgit@dwillia2-desk3.amr.corp.intel.com>
	 <156092350874.979959.18185938451405518285.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-06-18 at 22:51 -0700, Dan Williams wrote:
> Prepare for hot{plug,remove} of sub-ranges of a section by tracking a
> sub-section active bitmask, each bit representing a PMD_SIZE span of
> the
> architecture's memory hotplug section size.
> 
> The implications of a partially populated section is that pfn_valid()
> needs to go beyond a valid_section() check and either determine that
> the
> section is an "early section", or read the sub-section active ranges
> from the bitmask. The expectation is that the bitmask
> (subsection_map)
> fits in the same cacheline as the valid_section() / early_section()
> data, so the incremental performance overhead to pfn_valid() should
> be
> negligible.
> 
> The rationale for using early_section() to short-ciruit the
> subsection_map check is that there are legacy code paths that use
> pfn_valid() at section granularity before validating the pfn against
> pgdat data. So, the early_section() check allows those traditional
> assumptions to persist while also permitting subsection_map to tell
> the
> truth for purposes of populating the unused portions of early
> sections
> with PMEM and other ZONE_DEVICE mappings.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Reported-by: Qian Cai <cai@lca.pw>
> Tested-by: Jane Chu <jane.chu@oracle.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3

