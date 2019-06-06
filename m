Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB9EFC28EB3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 16:55:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A83120868
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 16:55:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A83120868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BEC576B027A; Thu,  6 Jun 2019 12:55:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9DBE6B027C; Thu,  6 Jun 2019 12:55:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A8C0C6B027D; Thu,  6 Jun 2019 12:55:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 56EC96B027A
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 12:55:47 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l53so4593842edc.7
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 09:55:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=epEjW5IpR6kSEZemo8/MWQhCGmzC7cOgrzu6vlv3or8=;
        b=gf94BHWjCf+3gwslafqJu1XRozw+HSNPqScAf4Egj0tnUqx00B1xorjE5kmEM8Bm89
         kyJG/L1yQgGaB4V+QN300N7HD9KWKY4y50kgXG1sfeUFp30q38tr7TFI3m4xfFEkWXlL
         0jJH+UvSSJpo+HFg9vJbiCtycJ/3Xyrwa9jlsUDvB+IRO0Pk1iUvaljXg6J+r+VHgTeT
         jeDgLijJFVdLkjG/CbZiPOfZMmKXVnfxJ4QL53Mh791Fn98p2qlYhnOcbHZph6dcu7Rs
         AvMFwSush7TemAzU5xB1d8jWpuTaFsSqNLYN62KVyZ1CGTbVR7cshPKx5/3xqMsVWPMC
         XqdQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXp55PNRk0+4SFhJxAozjECbKTotGmW8n/jeDjCDuDo7l/FYQPi
	XmM+NAZ8Lh5TpW0CH3un5UbSgdj88I3qNUsudhExhwiTpJeHKbWPhy8Ubw8jZg9FgFUoRDHPhI4
	0KB+6KxTy0qHuT/mzBtZZHyQ4q9a3CiQKRPdmyKOJc7YKvRVu59ygWmTeZKnxqbJuAg==
X-Received: by 2002:a50:95d3:: with SMTP id x19mr6250145eda.98.1559840146921;
        Thu, 06 Jun 2019 09:55:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCJ7WfHgeppBPVStnt6gCdjRbyaaMgnWn1ArZBKmMdrt8G7kZuZQA7MsPNhfb3JwXqAL9N
X-Received: by 2002:a50:95d3:: with SMTP id x19mr6250049eda.98.1559840145862;
        Thu, 06 Jun 2019 09:55:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559840145; cv=none;
        d=google.com; s=arc-20160816;
        b=rqld2IXC8pBwRROzobeMJtQybeiRnsX9g1drINempv9MCEKO0nBQlin53S+zO2V2al
         vDcYK40PnsMXr8+iDA68MPJhW+79sORfW1Ic65g4/invwtL86M6Fd4SIZgHDX5xtRr3m
         eiVzmwBExQBqGeNscnE0dKlFmFAqCVsj4O7khGevwt9K4KFx5CoU6Tg5S/Odh9ZhqciB
         qXB7IMVO+VOb3iYoVzT1jY/aqhXklcy7tLJGxU0I/QeU0JDV5ozYFWjhVIFQ2PxGOI47
         nkIerS3pElpTN3+B0Q/SwXCCkHyRFI62Yl95gkbT8GZTcOCnN2Ls3t2hfHx1rsH6a82g
         97Sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=epEjW5IpR6kSEZemo8/MWQhCGmzC7cOgrzu6vlv3or8=;
        b=yBSgWrAO6FGEdavWfViEvQH45dOYoceafjB6pJK8IXCthj3NEjUxmicXb53TUlADTO
         9I+pvY3T44RwDqm/iozOA/8Vfv6/yOZrHbaz9d8fzBLii2S8rmpUhV8fRW6KQpWQ9GRo
         yIp9rTjDXncd6IgHQqR2NZubLAi0Ho575FqVXo9WkpLzewUz1LGvzCmDd38Afs2J5TnV
         BI/26U7BX3wS5Ha5bSzbl5Rfp/kwE+DUVYNoI+UbLCiQ7pWZHaCs+/bG88bvOaAbAp8A
         NtFImoQZB9QnDYxtMw4mKebjzmaLqTg3c0x8AjLlReg0iV/p1ryHAMS5JZfZ09ITq+zP
         fhnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j26si2234302ede.86.2019.06.06.09.55.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 09:55:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4C0D2AC8E;
	Thu,  6 Jun 2019 16:55:45 +0000 (UTC)
Date: Thu, 6 Jun 2019 18:55:42 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Logan Gunthorpe <logang@deltatee.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Jane Chu <jane.chu@oracle.com>, linux-mm@kvack.org,
	linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v9 02/12] mm/sparsemem: Add helpers track active portions
 of a section at boot
Message-ID: <20190606165535.GA31194@linux>
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155977187919.2443951.8925592545929008845.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155977187919.2443951.8925592545929008845.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 05, 2019 at 02:57:59PM -0700, Dan Williams wrote:
> Prepare for hot{plug,remove} of sub-ranges of a section by tracking a
> sub-section active bitmask, each bit representing a PMD_SIZE span of the
> architecture's memory hotplug section size.
> 
> The implications of a partially populated section is that pfn_valid()
> needs to go beyond a valid_section() check and read the sub-section
> active ranges from the bitmask. The expectation is that the bitmask
> (subsection_map) fits in the same cacheline as the valid_section() data,
> so the incremental performance overhead to pfn_valid() should be
> negligible.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Tested-by: Jane Chu <jane.chu@oracle.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3

