Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59443C43219
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 07:37:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20A11205F4
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 07:37:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20A11205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C7FD26B0003; Fri,  3 May 2019 03:37:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C30E56B0005; Fri,  3 May 2019 03:37:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4F936B0007; Fri,  3 May 2019 03:37:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7D3B66B0003
	for <linux-mm@kvack.org>; Fri,  3 May 2019 03:37:47 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n52so2962674edd.2
        for <linux-mm@kvack.org>; Fri, 03 May 2019 00:37:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Nt2jn2H1MAha1fEnMZaAD+e5EhXfCX0BzoToD1NZaaE=;
        b=agZNOh5ZUOoZ4Jg4Unxh83ytXUeguea/U+90Vh/jCFaqmHWqz7erOvklPH4hUSNWVN
         PvQQAmgB8UMQVGV8EGXaCGbqO9vrSfYLNV+4vL29t6irzOGM7SgMaEZbWvcefjrOBE7Q
         0nFq2ZrO/HC4DK1/BNZcB0lgogp58HZF/F71sc2O9uV92Vd2vvTstr0gLBbJ8UVlDX+a
         plCDibXzd0parur/015Dp0WneaMf5Agqe4D1sLwJ88gtdA/nf1gw4sDSwZvDiJ9rvGsk
         w9TF+XpiMT0g15MPCFIduzKv1tyPDY9Y/PmcyxIx0gemUjTF7eR4AtxJ89F7in52wz2s
         tkeg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXOg4z/XI0r+FAC1SD+KJNGUBLzAN4kP9T8WXhO0vRp90hNVJKy
	gjzRdHudLSR14VQGwuoqlNkVTSJ0tYz7tpUpZLqQNQwohNdcpm19TToMLCXjzSTFIua8ZvEpHIx
	a7trk78+1kxGD8mg5Wio0rkVpj31I4HCXOFXfzOPnbyQZf5Sr8Gtl2a+JocAXxJ0Nzw==
X-Received: by 2002:a17:906:f84:: with SMTP id q4mr4916750ejj.117.1556869067019;
        Fri, 03 May 2019 00:37:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlwJYFFfOpYYP2jmefzdvIyrUptyJpR8cofgOHjvtXc7dNczmKequNiKwNiBahjBcHoWXc
X-Received: by 2002:a17:906:f84:: with SMTP id q4mr4916710ejj.117.1556869066274;
        Fri, 03 May 2019 00:37:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556869066; cv=none;
        d=google.com; s=arc-20160816;
        b=SLrLvI6q9vy9A5aHK5CjqEEINZK16UKFVxFzCpEiqjoudGT2vWsBVc4TAG1Y7CX5Bi
         4UzJoxw7qDEVbKbk5oXVWH2Ts+OSshKF2QvvFd+YMC4Fp7x6NJ+WTyLM9GjNu4jGXsdM
         sy3+qv8VdWOpx0z9/HccFyumfryA7LYxyGPL3aQ7kvTWpSWXifQAszWgLfstuozJoQ6e
         IIxhhjLNVSCSPd3djCSl3yjwRSSCs0buadKqUlyBOyrjN5bMqEaqp4eVkVC1oyhC7NGC
         TxFUWtR7N/4v8HUOLlqjwhqWnYBWQi/FNKzP9jLWSrLpHGl1Sd2T7y4d75Cc+LV8H91+
         E+vw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Nt2jn2H1MAha1fEnMZaAD+e5EhXfCX0BzoToD1NZaaE=;
        b=wjPONDCq0O3axyA5BJbke9Wh40GoxQKp7CNroBU15w6IBDWYbc3jd794Pt1lTFhZ2V
         T9uCrcF3K9/wUd3+fH4lpMO0da8nlSxz3HZdXHxM4l4yFGGvDmrxKSBOGFWrvkrSmiof
         D1o0SQiaPbYA0HBajx88x6wSq+3c2X0rEQD8BA/FECAGu6RobIO3JsMRurfE4VCVyAlH
         PF9xKyI3oqLXePfy1LZL1k0kxp6IZj24iYTjU5fRs1f168iMnFlvJ9hqYAmLZSQC695F
         kSKNu6DIREStTDslCG4BgvrLbJtYSTAce4nbqJqlSoyiAJNmN9Ib+rerOvo/bc+TLjAN
         KuXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c33si1023754edb.303.2019.05.03.00.37.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 May 2019 00:37:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C23D3AE0F;
	Fri,  3 May 2019 07:37:45 +0000 (UTC)
Date: Fri, 3 May 2019 09:37:42 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	David Hildenbrand <david@redhat.com>, linux-nvdimm@lists.01.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v7 06/12] mm/hotplug: Kill is_dev_zone() usage in
 __remove_pages()
Message-ID: <20190503073742.GC15740@linux>
References: <155677652226.2336373.8700273400832001094.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155677655373.2336373.15845721823034005000.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155677655373.2336373.15845721823034005000.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 01, 2019 at 10:55:53PM -0700, Dan Williams wrote:
> The zone type check was a leftover from the cleanup that plumbed altmap
> through the memory hotplug path, i.e. commit da024512a1fa "mm: pass the
> vmem_altmap to arch_remove_memory and __remove_pages".
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: David Hildenbrand <david@redhat.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3

