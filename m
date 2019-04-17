Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85E9BC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 12:58:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4556F20821
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 12:58:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4556F20821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2B626B0005; Wed, 17 Apr 2019 08:58:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB07D6B0006; Wed, 17 Apr 2019 08:58:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97A456B0007; Wed, 17 Apr 2019 08:58:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5B8736B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 08:58:37 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i17so613740eds.21
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 05:58:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fg3uwc/TLSQrSwyc37dj2XrJ2sSMbt3FjrpoJ9mDShw=;
        b=n7pIQqrGnWqFuRVaswip2VsBftEddH2RnPAFWg0gET65qll92Bo0KIoiEY31B0Xzc+
         z2aPaNbDXdax7agqbiKchGtoxUM1q1+VkrNsjcifXH4fLm52Yv2D+WSQDnHz9zUBW/21
         Cm67w0zr5d8qCrFHEDhgLF2fw4DwhG7kKBHZ14cnrOwBNK21cV1niz1dnWnRLkCfu/SU
         cQ5eXGzrzpxbJJ/+qKVH83u0D63vlwAeZycR003K2zNFedCfF5g3zTrfez8wmE8pVsMr
         ptcSnWMYGIi1HndC+p+PaaA4Kcflvv6rx5Bo0zaFNhUkqd4x0Eqg9BmnB4RpSAmNM7cC
         G4Rg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXW17FU1lweByRljGyANJTUXZl/o4rO+5wUqI4td4aSre4DIjsq
	Wm9HLbzRNcokl0svLu1hYpgwnv+tUCtU08uvMlzTkonxPWzGwa1cgmrN9OnovIKrcCi6sYponBi
	TvHoj663/0Y0aGQUNhJHiXArHUU8Xy4FjCTYuBdVCbx04lHIz5E0a25fB/+3EUAA=
X-Received: by 2002:a50:9ea5:: with SMTP id a34mr44202636edf.191.1555505916972;
        Wed, 17 Apr 2019 05:58:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxCEPrhqCOOmPdbUKuvGgvv318sM9+FMSoarNqUs6/tBlAWfHWX0ZchWH50aMTEJ6r3abEp
X-Received: by 2002:a50:9ea5:: with SMTP id a34mr44202602edf.191.1555505916239;
        Wed, 17 Apr 2019 05:58:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555505916; cv=none;
        d=google.com; s=arc-20160816;
        b=s3frCc3VNGoa9xgIt9YpwD8+/asLJ7tXChwtZBcLP/QzimzWZJ42Mvmoxmd7xr6xHd
         17rg0nnveVzTOKoRNe7rYwjsKOCKYBP+n9HGr6L424FlYIkrihd7KddWV+oS3rM0BN1I
         rIW72JdveAG2UcmoQU7X6d4YQvSfuspmfq4qu99KXDHbAc7jEMsYAMIKgxVrTqf9s79A
         q9S8/GIcxxMe8OPBne+yf//Hk+q8+NVyJwvKwhTIZy/VgyNAGaA35h5ONLMIPKzfXoZj
         ysluo7V/0xjDSZHt1i6pT8qYL5sqJZsV/JNkAROsamOSXqBflU3067zHSGq+tRVIe+jp
         QuZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fg3uwc/TLSQrSwyc37dj2XrJ2sSMbt3FjrpoJ9mDShw=;
        b=l8FG7O7SEIwC6rEamE7nssck8Db4SGDngZtKlxHsLuI+unusbCqvvPORdjy/nQ7q/W
         DaXeTe5jNzERNdToPWYtvfZvxksvgV/u0AnqbrmSG1bkP2eORgsP9OdFAByVXWc0KDSY
         3SaPRCkf7GYAikUrXF9d5aWrvHSG3PC38opB4MoqgVMxKywmdTY2id3X/y6yZuc5A0bT
         E1tqdaOxdJ9ZmopGivvl5JlOLsr4+o8ZLgGLLXt+pJoFquGVTu9SZzvp6UUA1yxt4Tgu
         5nNM30yXebQCdJtnrpLtZu1K5fGJfXzfnAndN1VJcEk86a3wtJgyR8B64Kog7LY2JtGX
         Hapw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v22si560166ejw.235.2019.04.17.05.58.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 05:58:36 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AE562B163;
	Wed, 17 Apr 2019 12:58:35 +0000 (UTC)
Date: Wed, 17 Apr 2019 14:58:33 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	David Rientjes <rientjes@google.com>,
	Zhaoyang Huang <zhaoyang.huang@unisoc.com>,
	Roman Gushchin <guro@fb.com>, Jeff Layton <jlayton@redhat.com>,
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH] mm/workingset : judge file page activity via
 timestamp
Message-ID: <20190417125833.GH5878@dhcp22.suse.cz>
References: <1555487246-15764-1-git-send-email-huangzhaoyang@gmail.com>
 <CAGWkznFCy-Fm1WObEk77shPGALWhn5dWS3ZLXY77+q_4Yp6bAQ@mail.gmail.com>
 <CAGWkznEzRB2RPQEK5+4EYB73UYGMRbNNmMH-FyQqT2_en_q1+g@mail.gmail.com>
 <20190417110615.GC5878@dhcp22.suse.cz>
 <CAGWkznH6MjCkKeAO_1jJ07Ze2E3KHem0aNZ_Vwf080Yg-4Ujbw@mail.gmail.com>
 <20190417114621.GF5878@dhcp22.suse.cz>
 <CAGWkznHgc68AHOs2WNPARmwMMKazuKXL1R4VsPD_jwtzQeVK_Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGWkznHgc68AHOs2WNPARmwMMKazuKXL1R4VsPD_jwtzQeVK_Q@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 17-04-19 20:26:22, Zhaoyang Huang wrote:
> repost the feedback by under Johannes's comment

Please follow up in the original email thread. Fragmenting the
discussion is exactly what I wanted...
-- 
Michal Hocko
SUSE Labs

