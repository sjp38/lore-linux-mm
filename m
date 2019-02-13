Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AD2BC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:36:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 167F821904
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:36:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="BpSrj02y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 167F821904
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C0CC8E0002; Wed, 13 Feb 2019 08:36:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8494F8E0001; Wed, 13 Feb 2019 08:36:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 710B58E0002; Wed, 13 Feb 2019 08:36:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 29AA68E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:36:29 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id q62so1700026pgq.9
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:36:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=cBBe+UcsahNoqnYodkBtr5c/iWyqknZT5QGdmf7j6eU=;
        b=pA8ZZyv9dzU8LDQU4tJX8AmFSWXJPP9fNBIQcVzx7kss4yGp5YsIlW3V5x9a9JGWLg
         wQEcsDpZ59WIhjV2TVZddewbPn2c8kzbRdRMExHX4ofLEDzThslENDs7Rd1P2IrdRDpF
         amJjviEzjjf6BBH/blpW9OWS6JC7j24sFGWi0Z4QzZno8MS37dyCgFXgs/hpUeaZxmp/
         JpLgHDxnO6ieyhDXw0xnPoMeblXpdYDdyY/nu2ku0zmupOmrGwKYgHg/KyLy/ET1l/RT
         XyUQt0wKmsCB5knhZ3dR287rvVLvSnUPCl5Yz7h6dK7HqWveVBkFdKx4WmwjBcRjsmCH
         UpMQ==
X-Gm-Message-State: AHQUAuYsqzUf05Ou0HyZ1lx9UoZHIZI4Xzz/ezwzQYBCdiT8yQ24AjFJ
	iO6pMW1SueHXn6gEOB7S9Dopakd4vZk/unm3FDo/Qhh0U0FS9R54mbINZpwlEXGMCZZ2RX7EmyE
	VBB+zma2tGO1cSFlinmvbbHNOOkYwMKnmBlfMCeNJ0QDhja0Y25g1baqRVb3rg8I=
X-Received: by 2002:a63:c04b:: with SMTP id z11mr499622pgi.135.1550064988807;
        Wed, 13 Feb 2019 05:36:28 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZIYO3Y3De8AJbURdBbhMe2Y3rpKfecophWRJ5xxmnk3mG8XqKyAjA7BTrO47RZTKth6GOA
X-Received: by 2002:a63:c04b:: with SMTP id z11mr499586pgi.135.1550064988094;
        Wed, 13 Feb 2019 05:36:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550064988; cv=none;
        d=google.com; s=arc-20160816;
        b=MXKCrxenmUMKTMsoHjviX/QKl/agDDgCOr++RSBjDdPY1O8rcfgkzc2E0OuKVGDyV5
         OBV1Ffh85XHQkejqNldJ30YP5u5sD1dR7YmDA0TRcn6xs7or30pP7h7cwWo3w9xXKDN0
         36d9A6sdRbB9uKAv7/0hLrq8d+d0XGLzS8XXRS1O5KmMyxsFoBK3uLkZkh78UkI29WZ/
         CP0thiUsoboR4tpng144FvUWiyfb24rKLvELJx2cMOH/knHBEE1VglqFA1a9dd5II/Bg
         HNHInZrF3BKxIRBMjRdlEn58wkgNv8uk2smDgfy/HfBHwVSBhaOkusxo2pB7lxmviTFe
         gguA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=cBBe+UcsahNoqnYodkBtr5c/iWyqknZT5QGdmf7j6eU=;
        b=Tvy8YUtdvA7z3JuLLRyD8xiMDN3YAOs8ypdqYYeMGzIJExDX/8Mj0uaRsDSdrqM5Cx
         B+Zl/0cZohiCm2LGSJgd61DXPVWNjukHDM41ih3xyUUVOW2Z2EQgC1PPChFVBUzd+oos
         IDTHo7awEBDiobsZ0hqsVQUxmoQicVRHody1GsbUhVexCC63yE53yFRSxKt/Vn2PZ8wh
         5Jksibeu/0fZrGk8M2OkakCoNCC7p+3b+x3/AWt745FU1TXstcge35h30StTrdU38beE
         2gF3prLpF3hxHA9IHQ+AxCQd74ciBwSS5QlaTM7dlO+dtQOlPrZcsHOl1tizmf5G2nLF
         FZOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=BpSrj02y;
       spf=pass (google.com: domain of srs0=8kuc=qu=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=8KUc=QU=linuxfoundation.org=gregkh@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w10si14893226pgj.214.2019.02.13.05.36.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 05:36:28 -0800 (PST)
Received-SPF: pass (google.com: domain of srs0=8kuc=qu=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=BpSrj02y;
       spf=pass (google.com: domain of srs0=8kuc=qu=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=8KUc=QU=linuxfoundation.org=gregkh@kernel.org"
Received: from localhost (5356596B.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3F2512075D;
	Wed, 13 Feb 2019 13:36:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550064987;
	bh=T71FDtFZoBA1eCh9qUuHolpuH0DcG5LdOn3nqWumweo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=BpSrj02y9BKNILk+2f3ko7JVpnvWFSgs4gqM/4fmCLpUR27/0tEwMF6aLnjs9Tj4n
	 uplvVy+x9WuB/K00lKPQrEZoObhujELgbagbPiswtculZc4uZZYQkaKn6AvenlMqvo
	 WxWHS0TNYVdBWuJHOHJ1DgEIoHDrXOfITpi+HHE8=
Date: Wed, 13 Feb 2019 14:36:24 +0100
From: Greg KH <gregkh@linuxfoundation.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Hugh Dickins <hughd@google.com>, Liu Bo <bo.liu@linux.alibaba.com>,
	stable@vger.kernel.org
Subject: Re: [PATCH] mm: Fix the pgtable leak
Message-ID: <20190213133624.GB9460@kroah.com>
References: <20190213112900.33963-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213112900.33963-1-minchan@kernel.org>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 08:29:00PM +0900, Minchan Kim wrote:
> [1] was backported to v4.9 stable tree but it introduces pgtable
> memory leak because with fault retrial, preallocated pagetable
> could be leaked in second iteration.
> To fix the problem, this patch backport [2].
> 
> [1] 5cf3e5ff95876, mm, memcg: fix reclaim deadlock with writeback

This is really commit 63f3655f9501 ("mm, memcg: fix reclaim deadlock
with writeback") which was in 4.9.152, 4.14.94, 4.19.16, and 4.20.3 as
well as 5.0-rc2.

> [2] b0b9b3df27d10, mm: stop leaking PageTables

This commit was in 4.10, so I am guessing that this really is just a
backport of that commit?

If so, it's not the full backport, why not take the whole thing?  Why
only cherry-pick one chunk of it?  Why do we not need the other parts?

thanks,

greg k-h

