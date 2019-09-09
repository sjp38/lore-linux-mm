Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFEE1C49ED6
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 15:42:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 789D92089F
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 15:42:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="THRGm6XS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 789D92089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7FBD6B0005; Mon,  9 Sep 2019 11:42:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2F486B0006; Mon,  9 Sep 2019 11:42:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D20CC6B0007; Mon,  9 Sep 2019 11:42:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0200.hostedemail.com [216.40.44.200])
	by kanga.kvack.org (Postfix) with ESMTP id B22686B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 11:42:58 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 5D372824376C
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 15:42:57 +0000 (UTC)
X-FDA: 75915800394.30.train14_711207f192e5e
X-HE-Tag: train14_711207f192e5e
X-Filterd-Recvd-Size: 4246
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com [209.85.208.66])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 15:42:56 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id f2so7041494edw.3
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 08:42:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=3SY6sV9Kk+QzFkjSL8M3PFN8ScqMIVwbQKKnfeSopA8=;
        b=THRGm6XSaXwL6nkGJIUR36arIzUbwIyDFRDA3U5m/qBxDyOb3Hxa1xgQlnvTWnFdD7
         6hKRYrgaQ41tvn6TVGF+3t0pAOXAxC58CqB1h7e+HifutUHr4IKnnJUV7uDcpMSn97nV
         MMicdUmqzBFGNjMitH9NhuJ7ZsJl9i0MBYutjCuI1A+rpvKILL++D7uffSa24gGDAPyS
         CsIzReY/kMAl3Hos2OL4D7sCUlnjKuPXjI7TlAj+RHgAZWTtlcxjo0Qe2jpSl13orlHl
         8lRZqVc3vd67K7Hq9Zg00XrQlcORq0O3/fxVQv4ibxpOBbzRAw19XqGUqnigtTpgERWr
         jYew==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=3SY6sV9Kk+QzFkjSL8M3PFN8ScqMIVwbQKKnfeSopA8=;
        b=iP/vc58PJN145h7QYag1ElEJxnyq9615jSiFEH65TmT3sxKFYkEkeKgawiVJCkIbK5
         FJ5QxDJYqekr63MZJlQCRAX6De+aV1WLF8l0ozcH31g5A0cZ8qbwA8hpdhZFMX3sgRKQ
         qGK0DG69i8rIDPYYqs4UjzQzylyT1gphBQuwnCIvgYXcYHHAX6aerBVTnlSuDP6UIEO5
         QpSgoEtm+qTwidDKM8a8xBq3PVEXPWMYeX97yA/lL2083zB960q5LaCpd08+rCdsMJmd
         H8rg6fK4IZhNmej7uXKzmlIcoqFvBfbHF14+xo1M/8fh8CQ+sNIi92RXLY1Ph7FKd5j8
         yeyg==
X-Gm-Message-State: APjAAAWE35S133i6JoxSapwfqZd7CX4J623lH+QoDvBjWee7c8XqiC6D
	FzREpvUv1GEiwbt5WRvzxWGUOg==
X-Google-Smtp-Source: APXvYqyrmYxxvoaUBmgmwXh89G4Un8byjESE4BZ9R71RK07xOPzKxwas5qjTsrE19iMlwaLhtmZwvg==
X-Received: by 2002:aa7:d818:: with SMTP id v24mr4767421edq.23.1568043775730;
        Mon, 09 Sep 2019 08:42:55 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id a3sm1782816eje.90.2019.09.09.08.42.54
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Sep 2019 08:42:55 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id D32491003B5; Mon,  9 Sep 2019 18:42:53 +0300 (+03)
Date: Mon, 9 Sep 2019 18:42:53 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
	sashal@kernel.org, boris.ostrovsky@oracle.com, jgross@suse.com,
	sstabellini@kernel.org, akpm@linux-foundation.org, david@redhat.com,
	osalvador@suse.com, mhocko@suse.com, pasha.tatashin@soleen.com,
	dan.j.williams@intel.com, richard.weiyang@gmail.com, cai@lca.pw,
	linux-hyperv@vger.kernel.org, xen-devel@lists.xenproject.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/3] Remove __online_page_set_limits()
Message-ID: <20190909154253.q55olcm4cqwh7izd@box>
References: <cover.1567889743.git.jrdr.linux@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1567889743.git.jrdr.linux@gmail.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Sep 08, 2019 at 03:17:01AM +0530, Souptick Joarder wrote:
> __online_page_set_limits() is a dummy function and an extra call
> to this can be avoided.
> 
> As both of the callers are now removed, __online_page_set_limits()
> can be removed permanently.
> 
> Souptick Joarder (3):
>   hv_ballon: Avoid calling dummy function __online_page_set_limits()
>   xen/ballon: Avoid calling dummy function __online_page_set_limits()
>   mm/memory_hotplug.c: Remove __online_page_set_limits()
> 
>  drivers/hv/hv_balloon.c        | 1 -
>  drivers/xen/balloon.c          | 1 -
>  include/linux/memory_hotplug.h | 1 -
>  mm/memory_hotplug.c            | 5 -----
>  4 files changed, 8 deletions(-)

Do we really need 3 separate patches to remove 8 lines of code?

-- 
 Kirill A. Shutemov

