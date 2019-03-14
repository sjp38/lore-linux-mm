Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45EE4C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 18:15:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED68220811
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 18:15:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="JKJ8ypVg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED68220811
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81FA56B0003; Thu, 14 Mar 2019 14:15:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7CF8A6B0005; Thu, 14 Mar 2019 14:15:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6BEF16B0006; Thu, 14 Mar 2019 14:15:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2CAA26B0003
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 14:15:51 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h15so7084963pfj.22
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 11:15:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=BJi1xy68bq5qAreRWeW3balweh2jjwqZ0a07CcPR4VI=;
        b=hWCCQt6kpqMKQc7IP9Z1EuUB8dgOWdtSmI4mJIJe0lCUE5eBlhcFFLhLy78VUe/w64
         wtvnE+7JXfAU9SIYhp9QvIQm2clx6W7YgALlz9CQCxIHOQRCPDERC1BG39WKwPnwPWLn
         OdY+EX17jS43si1uXVVE+hyuJD5rv7CUxaP3DDF3RGyPEelx0SusY3GDgFuw4bF0uGUd
         cYd1AqAZD7OAIjr0O+sj97C+yZthOonwDWBPxarp4OVhxeYZ5L4CsVPrAMUI3xcI4xPm
         2GuvZjW67Ct4ARtlcY3EzvzsFdph+Rgb+qNYbq1QeLLw108ikZyuTpuz1GIJ1fNWc61e
         h/rw==
X-Gm-Message-State: APjAAAUpcqWpbQWNcfHAU8PWlR425onEXpXM2rya23ULxWnLXkbTrPAP
	Y6jDzX0H3+UzHI5fhf41HeArUCJvXW+2zYaNVxeC3wceD02HnLchFAuAAKuLOMlgF+SXaVR70X2
	AHCeb9+zCHbkvYDdQEryA3RQDOMpo3uRN0QEmqcEIjUJBoBBQ/1psFG0tR/agTS5wlAgVOw++lk
	ZRXX0KZIMWxQKnGGR2G2WRE00TUwsGjSOvq9U4Bxj1Z7mhUJR+qXGN1ExcKr8qt9BxdobN0gOWz
	ghIuREjcdOMwkgjIOdDSPZWmOFTNR/ZjAWXU+EFidDsAAhWBaUvxh+VmlwCmTdnvWoDBJ0tRjyQ
	kEK2cJSlCHiPfOhdHkneK042KIwnESVDnMYCbKRxDjiu2U/CGTdGJ77dqPKmS87ja7YxRpl0mVq
	/
X-Received: by 2002:a17:902:b493:: with SMTP id y19mr53989871plr.9.1552587350779;
        Thu, 14 Mar 2019 11:15:50 -0700 (PDT)
X-Received: by 2002:a17:902:b493:: with SMTP id y19mr53989795plr.9.1552587349871;
        Thu, 14 Mar 2019 11:15:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552587349; cv=none;
        d=google.com; s=arc-20160816;
        b=tVU7eVlog7NSGshSq0ECh2VxvgORWdDb5uKrLigOY/ipquwiQqWFrOJdXssYbfZrkL
         hDEXVpVi4sGoc8B8wI/o8taXBXds3c2a/niPpMsEyhUSvm6NrGySjh9sE6Q0lb5bOMcv
         RUw6TlFd4zekkZeYmI9YKQUU6t2+coOIrO8Av5gELK6jhrk59fvf8O7om5thEDy/bjfl
         m+EMrnPgRre02CiQTF8deqmVl167U10nhDdadI7jBCHJ3AWbP2Gk0bmUDWKBBQovDSOA
         h3jQQzV1xLf72hTpvi8vGi9XkoXrPdMpGCAfoaK7oiA1kkgT+6eDYesuxgB/Q0NPP+HX
         Xc5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=BJi1xy68bq5qAreRWeW3balweh2jjwqZ0a07CcPR4VI=;
        b=l2QYYFpgJfW44kwzISh2XntEUPA7g/TdnM2xQeOYa8agfucW4a9TGVwnOAro7Mm17U
         vwKyKEmB/lQXLIjSXSTD8O8phqu2U6mO1PPq/IRSXVjAHSTzF+xjIzDWkAN+FsOCSnsC
         3CH3Q2MN4azfKIgkjAPYRK2zTAXvszrOzZDtdOweKWCbljBZsUz5qEJ3U3cMATgKu37j
         nz6wDOcileHUzdAtt9dWx23m1cZEHTduNGgXbRU7JvbpwxVmjdc5+2zKQfS0JOOTJB8E
         VTU/+RCod/DRBlPWvZ2TZXtKH7kus9xdlKLcliMRgtkk3ElwOzNKXSdTakHT9ovXRcH9
         ooYg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=JKJ8ypVg;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h128sor24245117pgc.33.2019.03.14.11.15.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Mar 2019 11:15:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=JKJ8ypVg;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=BJi1xy68bq5qAreRWeW3balweh2jjwqZ0a07CcPR4VI=;
        b=JKJ8ypVgaCETmFt5up7xdb9Csbo7aksbewz1aOhnShmgI5nnGPaPnKYgnD8wQjTe6j
         l00gaH1nq6LfFQ/dskOlD8JnPshO66R47G8p9Wg/d+m2ucCZV3bNog7OOvw9kx/cf5wq
         q4mcC6Xwh5RuThrnsPTL9XJPua+PTEkaYy0YVnUUhL6oPv6t3PGTJqdEipVeciR3ci9M
         1h4M0oQhn4mgQRt0osrtu1DPLVwKPzVVMSmGMXidxtpx6F6GryzpZjX4QV2FK0KegolJ
         RNK8flm3Oc0wiz2sIDPcZ7XAG8FZzwh/VAJkFMpLTBUxHmyklkvFBsghHYIeMCwr/q9P
         w8wA==
X-Google-Smtp-Source: APXvYqy1cLwDX2XwAgk/ndkbJleevjoXqrThV9BQ+2pW0/7lieb/R5cwb/PePBLXFejbihLbNrnPfQ==
X-Received: by 2002:a63:6881:: with SMTP id d123mr46083771pgc.10.1552587348935;
        Thu, 14 Mar 2019 11:15:48 -0700 (PDT)
Received: from [100.112.89.103] ([104.133.8.103])
        by smtp.gmail.com with ESMTPSA id k12sm20777179pfk.109.2019.03.14.11.15.47
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 14 Mar 2019 11:15:48 -0700 (PDT)
Date: Thu, 14 Mar 2019 11:15:22 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Takashi Iwai <tiwai@suse.de>
cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.com>, 
    Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, 
    "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
    Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2] mm, page_alloc: disallow __GFP_COMP in
 alloc_pages_exact()
In-Reply-To: <s5hpnqt5ob2.wl-tiwai@suse.de>
Message-ID: <alpine.LSU.2.11.1903141103590.2119@eggly.anvils>
References: <20190314093944.19406-1-vbabka@suse.cz> <20190314094249.19606-1-vbabka@suse.cz> <20190314101526.GH7473@dhcp22.suse.cz> <1dc997a3-7573-7bd5-9ce6-3bfbf77d1194@suse.cz> <20190314113626.GJ7473@dhcp22.suse.cz> <s5hd0mtsm84.wl-tiwai@suse.de>
 <20190314120939.GK7473@dhcp22.suse.cz> <s5ha7hxsikl.wl-tiwai@suse.de> <20190314132933.GL7473@dhcp22.suse.cz> <s5h5zslqtyv.wl-tiwai@suse.de> <alpine.LSU.2.11.1903141021550.1591@eggly.anvils> <s5hpnqt5ob2.wl-tiwai@suse.de>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Mar 2019, Takashi Iwai wrote:
> On Thu, 14 Mar 2019 18:37:06 +0100,Hugh Dickins wrote:
> > On Thu, 14 Mar 2019, Takashi Iwai wrote:
> > > 
> > > Hugh, could you confirm whether we still need __GFP_COMP in the sound
> > > buffer allocations?  FWIW, it's the change introduced by the ancient
> > > commit f3d48f0373c1.
> > 
> > I'm not confident in finding all "the sound buffer allocations".
> > Where you're using alloc_pages_exact() for them, you do not need
> > __GFP_COMP, and should not pass it.
> 
> It was my fault attempt to convert to alloc_pages_exact() and hitting
> the incompatibility with __GFP_COMP, so it was reverted in the end.
> 
> > But if there are other places
> > where you use one of those page allocators with an "order" argument
> > non-zero, and map that buffer into userspace (without any split_page()),
> > there you would still need the __GFP_COMP - zap_pte_range() and others
> > do the wrong thing on tail ptes if the non-zero-order page has neither
> > been set up as compound nor split into zero-order pages.
> 
> Hm, what if we allocate the whole pages via alloc_pages_exact() (but
> without __GFP_COMP)?  Can we mmap them properly to user-space like
> before, or it won't work as-is?

Yes, you can map the alloc_pages_exact() pages to user-space as
before, whether or not it ended up using a whole non-zero-order page:
alloc_pages_exact() does a split_page(), so the subpages end up all just
ordinary order-zero pages (and need to be freed individually, which
free_pages_exact() does for you).

Hugh

