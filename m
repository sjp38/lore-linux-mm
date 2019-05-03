Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A535CC43219
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 19:52:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5741B206BB
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 19:52:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="Y2+mqpv1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5741B206BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E50A36B0005; Fri,  3 May 2019 15:52:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E005E6B0006; Fri,  3 May 2019 15:52:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF0316B0007; Fri,  3 May 2019 15:52:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id B18266B0005
	for <linux-mm@kvack.org>; Fri,  3 May 2019 15:52:11 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id 18so7135181qtw.20
        for <linux-mm@kvack.org>; Fri, 03 May 2019 12:52:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ivgmrdOFqYbX906OA4N9N8K+zP87FPliWqhK06GaWhc=;
        b=Nq24irMA6AuxRMccYHdo/d12rXyOo50VdJQR+Pi/aE9bMnJbciyJ+xT29leFsl0+sl
         Qs1Nj7/FlqwP/q/BP8jrkoDc0JG1KMYAAUZVBiO/at+gPXAUuFVdOc140cUZYT3ACsbJ
         /QACjJJKpsxrJH++Wbu1Q3/pZYK9wpzdaK8jREzrpBKr5Z7iQIztrtVnoLB9dIPMJTFi
         +QGvoigKDDS4Js9d4Ra2L8YVgodQuggSlUBPn3P+ewWFSfUPL/UfOLiwFp+L3K81W5qa
         q31r2YiwFdUSqLs3zt4EQB3BmqXfGRP2/RvvVkYxVa0SFfhFQ+A6Z60hZ4v6LsywBQ9h
         2fQQ==
X-Gm-Message-State: APjAAAUNPoEJiU6avuBmTV+BEQQ/u/9+APiLNIkP2BFM39c9OvPQL8Ul
	M0IOtv5FRSxT21feB9lwFBZDuix4PoCyDBGREVz2ctDYki28YI5z4bowI8QsUfJjFfG8/M/1iE3
	/hJi3iPd/yn+Lk4g5INRXkt0Ui+owMD+qraLFLiZ72wkyIjW2CPXC4ydxHhEPSLd6WQ==
X-Received: by 2002:a0c:9694:: with SMTP id a20mr9495517qvd.236.1556913131469;
        Fri, 03 May 2019 12:52:11 -0700 (PDT)
X-Received: by 2002:a0c:9694:: with SMTP id a20mr9495469qvd.236.1556913130580;
        Fri, 03 May 2019 12:52:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556913130; cv=none;
        d=google.com; s=arc-20160816;
        b=URn1F5NOlxrWlMFK8jCh5EL8O1LOU46fEAFn2ZvJNQD6G6mh9jWHSG4MT64DpAxrx+
         oA70Vb8fPICPTS3+bhtNV7Ms1aV80E/fCau0VGhYHuJPXEnosyX2gA/+pyZg6hHOK2YD
         6iA5VfHeF5XJa4jMdXM1y5QfdHaO+5eVpvRj4q+0kTjjnYYtAmmIsWMTuHqcf6lVxY9c
         tpto/3Fo3xV16kdYBhifL/bFLES5ha9btdfFAjjcgvlC+6RZ4cSe2UPDwOAdPtM+Hx8J
         MP+Q0jyMpnhXq3VjnqlJPMvWYXVP/Cv1+N3w5nso+JmONhqoU55ACB4J9PaajZSolo9l
         rjcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ivgmrdOFqYbX906OA4N9N8K+zP87FPliWqhK06GaWhc=;
        b=PJrBbdxCwb6ULKX5aZYpHGr7e2T5RPmTyAIqHIkaCv8BEkqOWF8yDfQB6i+pUPSuDW
         eyOXqhOn6fpBihIFzqG412aau+Ps/G5+cLOpt0Aq8HL6x1TwfTOZQpzG9a2VKZbqaPvw
         5CsIHVS4M6tAY3acFhl5dvDuSKggHuq1j+IdxRhXyx0czDhboATS0bnOYpuMXnx38ul3
         2Nx/xSN86eifeNu2IsusdpX/4kT+CIIlE1Zw+EfSCH4u4Kva9/15h7Ch8FBLBLzqLuBg
         who4U3uPa7uxqRK2+aoYbR3sr8RbdLRDSiojqBSecRN7Az1Epnl59P+DJLJyWPdb9Wdw
         YVwA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=Y2+mqpv1;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n128sor1902166qka.3.2019.05.03.12.52.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 May 2019 12:52:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=Y2+mqpv1;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ivgmrdOFqYbX906OA4N9N8K+zP87FPliWqhK06GaWhc=;
        b=Y2+mqpv1ToBfZomGR0KiG0kJTC7Pd0/kQpdMHTLgCyV+gSUCOY8qdd9UCYmiwv8VrP
         a0P2nQSotvfAV+CN79oMGzR3siWxg++Ro/Nh7074im6lvktjpD8hIg0qMeLNeViPAb5p
         Ak6AnFNXIYyOEpaZmHFL4DjYbaTMMsJPHWbtlDryeNYlH9CMipo59Z5bwqt6LnH+866y
         no7ekuTp5m99+xYSlNrDLBL8TWLAbgPMf3WhIiwOO3hmFCWHFVznd4vHpEhYyKrruUob
         /WctC1Yd5I8cShP8X4p/ZyVtrGhsfMRHJnAiQwD7vi7EwWffIOwvaHGiK0CMeMDge/gC
         3dTg==
X-Google-Smtp-Source: APXvYqwhEb3DduJH9sxXZb04NbmAIe9orgplVqZkdluZyv5W3gUxH6ho/Vp1ktRhA9nOhgZWzjVhcQ==
X-Received: by 2002:a37:b802:: with SMTP id i2mr8702107qkf.343.1556913130058;
        Fri, 03 May 2019 12:52:10 -0700 (PDT)
Received: from soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net ([40.117.208.181])
        by smtp.gmail.com with ESMTPSA id g55sm3082470qtk.76.2019.05.03.12.52.09
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 03 May 2019 12:52:09 -0700 (PDT)
Date: Fri, 3 May 2019 19:52:07 +0000
From: Pavel Tatashin <pasha.tatashin@soleen.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Logan Gunthorpe <logang@deltatee.com>,
	Jane Chu <jane.chu@oracle.com>, linux-nvdimm@lists.01.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org, osalvador@suse.de
Subject: Re: [PATCH v7 03/12] mm/sparsemem: Add helpers track active portions
 of a section at boot
Message-ID: <20190503195207.l7jrr3z4halukycm@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
References: <155677652226.2336373.8700273400832001094.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155677653785.2336373.11131100812252340469.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155677653785.2336373.11131100812252340469.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 19-05-01 22:55:37, Dan Williams wrote:
> Prepare for hot{plug,remove} of sub-ranges of a section by tracking a
> section active bitmask, each bit representing 2MB (SECTION_SIZE (128M) /
> map_active bitmask length (64)). If it turns out that 2MB is too large
> of an active tracking granularity it is trivial to increase the size of
> the map_active bitmap.
> 
> The implications of a partially populated section is that pfn_valid()
> needs to go beyond a valid_section() check and read the sub-section
> active ranges from the bitmask.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Tested-by: Jane Chu <jane.chu@oracle.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Hi Dan,

I have sent comments to the previous version of this patch:
https://lore.kernel.org/lkml/CA+CK2bAfnCVYz956jPTNQ+AqHJs7uY1ZqWfL8fSUFWQOdKxHcg@mail.gmail.com/

I think they still apply to this one.

Thank you,
Pasha

