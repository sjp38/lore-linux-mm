Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54AFCC48BE4
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 17:00:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23CC420656
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 17:00:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23CC420656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B49526B0005; Thu, 20 Jun 2019 13:00:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD2918E0003; Thu, 20 Jun 2019 13:00:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99B498E0001; Thu, 20 Jun 2019 13:00:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4C3346B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:00:43 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so5073265eds.14
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:00:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=53alzYHZWlIfskjCCGqjODeN0RzG76iOlO0IPw69d04=;
        b=rHOJZ9wlmxqpGIRBL74ymIn21ky3470MBwR6Rh7ZepeN63C3uGu0ZacqLv6c7T8YqU
         PWdSnr8rTBYT2qp5HNX+5qaZWpXi8aACc/wFQpLU25ijqrsB4zW0TURA3dvbVBfU+XRn
         c3q75s6dP5oIKu0hvmzVClbmYBowtVVMR/3Lz9YjZka3O1w+rKMcDsb6Jj9cADI9APLh
         oTUIxPCMFmXofrOTZ8IY36DMXj2+VHQdanBF3yzajZbv9nHYr3rjbJUd4JZekMG6b0Qh
         h243hH2KqbnUXgpSQXzOSqdCMp6oJ3093NoC4Tg0fOUmJAg2ZKvKW8UUDn3yOE4WJ8E3
         FMkw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAU4Df2yj7fGICpaOantvGVFAGsf7yaRygh/gCvLfDBJThyF8sdu
	AGfrslxE6ZKnXXGUn86IdIVobdOz4F6DGP9MWp4dKdNTOH1dusjvIeBEticGMgQqF1FgQEfGrqw
	w3ooMf0YupXgaZtUWFJhVMxmACUYPwpdbz+T+udOzjzalzvI0Km84Cezl2AiC9jCUrA==
X-Received: by 2002:a17:906:25c9:: with SMTP id n9mr2386664ejb.51.1561050042828;
        Thu, 20 Jun 2019 10:00:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOk7EAlL2msUv3kfAu8B2s6288IhzArrQeLQqGYwoPZh6FhatlxkTlNP+KtP46aWZBYX6u
X-Received: by 2002:a17:906:25c9:: with SMTP id n9mr2386578ejb.51.1561050041926;
        Thu, 20 Jun 2019 10:00:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561050041; cv=none;
        d=google.com; s=arc-20160816;
        b=CsnBC384LhO8VeK4TVeVQhco201OHPQ1elMrHz5I0gZdJJ0GR2dQDP36Qn6bIyY5cs
         wnFMyu+eKZp+JCT0q9nbKPxGdCohbPJBgruGhaaLle/9m8meXhIUkMxWPx0kiYjWG5RK
         HDnjG4AKlyUayobOMDzSYZepXRFWKnbiSpofJu1Gztaw2ucS5cH0a8OAl3L4GDg2h7D/
         VX9T0HBgHLQoq2EJPiobaQpHXaqm3WATcP4Hmj7VQg4CFXi5Gg5KjgMDUekg86ogQJkd
         qywfBjJ1VHzZKIefRIwBj5bXv1JH0yfimKlg92lvDPXwqmFzuHduO+wCKMUnS9HsKL3f
         ELAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=53alzYHZWlIfskjCCGqjODeN0RzG76iOlO0IPw69d04=;
        b=LeUvXlNbbqxzdab6op1+PJngUeYlCTeB/Q+MFSFeAOF7jfiitRcv/QLBymWNXpakdK
         NvYR4hTgGBKaEF3LxjZUKZXHjzCmmEJ3N93pY2dtw2S7X1OYf0Rue9ctMVo00eLWr9LE
         bI2tlZsDCTm8Fo6MDoXnavhOaORE/8Oz69fdmz/Bmn46pPZO1qYVUl5w22k6+uY4vXZv
         SDN5O6Vyi6MhKywj/XVrMhXvlOlXSLk3ExV/5Vjdpd4rMJQkAvQVeVEJG4o4UFGclJRJ
         m9boTzDvU/tcmwGPI8kezk0jjfk6FOMBAtt5ADHXz/bykgnJPViqp//YnhaqLTmhiCHT
         PD3g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l32si356272eda.124.2019.06.20.10.00.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 10:00:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 89D3BAFC3;
	Thu, 20 Jun 2019 17:00:40 +0000 (UTC)
Date: Thu, 20 Jun 2019 19:00:35 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, David Hildenbrand <david@redhat.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Mike Rapoport <rppt@linux.ibm.com>, Jane Chu <jane.chu@oracle.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Jonathan Corbet <corbet@lwn.net>, Qian Cai <cai@lca.pw>,
	Logan Gunthorpe <logang@deltatee.com>,
	Toshi Kani <toshi.kani@hpe.com>, Jeff Moyer <jmoyer@redhat.com>,
	Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
	stable@vger.kernel.org, Wei Yang <richardw.yang@linux.intel.com>,
	linux-mm@kvack.org, linux-nvdimm@lists.01.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v10 00/13] mm: Sub-section memory hotplug support
Message-ID: <20190620170027.GA7126@linux>
References: <156092349300.979959.17603710711957735135.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <156092349300.979959.17603710711957735135.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 10:51:33PM -0700, Dan Williams wrote:
> Changes since v9 [1]:
> - Fix multiple issues related to the fact that pfn_valid() has
>   traditionally returned true for any pfn in an 'early' (onlined at
>   boot) section regardless of whether that pfn represented 'System RAM'.
>   Teach pfn_valid() to maintain its traditional behavior in the presence
>   of subsections. Specifically, subsection precision for pfn_valid() is
>   only considered for non-early / hot-plugged sections. (Qian)
> 
> - Related to the first item introduce a SECTION_IS_EARLY
>   (->section_mem_map flag) to remove the existing hacks for determining
>   an early section by looking at whether the usemap was allocated from the
>   slab.
> 
> - Kill off the EEXIST hackery in __add_pages(). It breaks
>   (arch_add_memory() false-positive) the detection of subsection
>   collisions reported by section_activate(). It is also obviated by
>   David's recent reworks to move the 'System RAM' request_region() earlier
>   in the add_memory() sequence().
> 
> - Switch to an arch-independent / static subsection-size of 2MB.
>   Otherwise, a per-arch subsection-size is a roadblock on the path to
>   persistent memory namespace compatibility across archs. (Jeff)
> 
> - Update the changelog for "libnvdimm/pfn: Fix fsdax-mode namespace
>   info-block zero-fields" to clarify that the "Cc: stable" is only there
>   as safety measure for a distro that decides to backport "libnvdimm/pfn:
>   Stop padding pmem namespaces to section alignment", otherwise there is
>   no known bug exposure in older kernels. (Andrew)
>   
> - Drop some redundant subsection checks (Oscar)
> 
> - Collect some reviewed-bys
> 
> [1]: https://lore.kernel.org/lkml/155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com/

Hi Dan,

I am planning to give it a final review later tomorrow.
Now that this work is settled, I took the chance to dust off and push my
vmemmap-hotplug, and I am working on that right now.
But I would definetely come back to this tomorrow.

Thanks for the work

-- 
Oscar Salvador
SUSE L3

