Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61DD0C282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:27:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 286AE217D9
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:27:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 286AE217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC56F8E0169; Mon, 11 Feb 2019 16:27:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A74068E0165; Mon, 11 Feb 2019 16:27:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 93B8B8E0169; Mon, 11 Feb 2019 16:27:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 53B438E0165
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 16:27:05 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id i11so288727pgb.8
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:27:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=uohh7hM0Bw5kEa3jfEtUyhxC1zxgnaJFyh7a3jj4pSc=;
        b=Y1qVKiy+ZVteTF9uC4Or/OUyDnvAppNtMSii++hNRZMmqW1mf4MLe+XnpgznEAoWwR
         r55ZioDuJBbauyv7bgETBsthPK0rYVceK7mJoPjxgkeSDkCJgfBkUrdtpaf/F28y9MpG
         gVTEWptM/aLGIVoUiGkTLDnrl51SJ+tJaLKsizurg7e8n3MT18MpSXk9nasD8enwS2zK
         iwv23xRHwhFVyPEpVLsTaymIWnzOlVy8DnAj4oueQ7uO+cU7aUcKW5CU8nVWOPStC732
         BkbUDTASCpiDLVed+bYd30PHT5RYc6CVZPLz06x2jIotxAsjU7UxIITeguZNQXg1uwwG
         3wbw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaeFbanOqQvPXB6E6plE/B/w5y5df89Oe/3LwKJs0jGBW0ZP+dZ
	gLC+kn27oe3xyS0XejrUd0Bp8p31cx4qt09zfK4tvE0LkjBDLtmxpREW04o7xUbumDZZoOAzjmo
	04wSg2L8t+2ctNbnjIwGU03zcqMKao/wqnK0mzQQqfDOiBq4OoVoyzN32JBjxsotDXg==
X-Received: by 2002:a63:d5f:: with SMTP id 31mr292510pgn.274.1549920424985;
        Mon, 11 Feb 2019 13:27:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia6r9BaKvL641DvgyjY6cOc//JYLBkn9yehKYXvLg8v5tXWWSSbDLWrKyaSPy6X2meyxdPe
X-Received: by 2002:a63:d5f:: with SMTP id 31mr292465pgn.274.1549920424198;
        Mon, 11 Feb 2019 13:27:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549920424; cv=none;
        d=google.com; s=arc-20160816;
        b=Ry0EaLJkGg4/pm6tTe4A/vopTjTQ5B1EeMi2zyUkKslJFfpO2rzfTWwqrfFzIPVrKv
         79FLjSc0SBnzu/Oxg9PYFR3tq6L9XyBvn1uiuaeZibFjm/SXMj6qngdYYXRuefOiLWjY
         x1tqpC4DXtVgDoL3ihF6XxbSGSQlmK77IgXxAXkHRsZk4tZzEdt8kdAh4xou9h9MiUzT
         hBylFSyMSTsYJfD6oshO5Bkg0y7Ep63SQLcdGF7WRMofcS64bbdtkS5MCzMtsrQ4Iezq
         b4NXPQaZDF0tCrv3GHgFHCx6dnqflNygnF/p9ZqnA56FtznnMzYLjDhF+wnXOKqILGrg
         VGEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=uohh7hM0Bw5kEa3jfEtUyhxC1zxgnaJFyh7a3jj4pSc=;
        b=R/mGX15MGDlFnGD50MN4pbOI5/8AXMGt9wvbgT3J1+u3hOEMV+A/3AX/AnWLW5daf2
         64YFRcubnjPxjZmDZLobsyL9NySjnqgzO4kw2OKnslpJRjeW2FTZFEjU9SeGKYhtPxNA
         pJdyikDvA0hnOgSbMLDNqEtVZs9leT5jvskA734CKwYI4ZOQm5F/5XmsQdwM1AU9T+Dk
         aWgG2k7jc6r6lTEdNiIb9lFtbROnu7nEvUlHElfRGYpVa4cWgMDIdiAR9VoIb9tNUjR+
         fRqsi/643wt1tIrsy9a/m9gNW+jToFBbphQGyeQeUkGqBNjFNPz//WlvbefDPR/yQrr9
         4H5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id u188si9282165pfb.232.2019.02.11.13.27.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 13:27:04 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 13:27:03 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,360,1544515200"; 
   d="scan'208";a="121657772"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga007.fm.intel.com with ESMTP; 11 Feb 2019 13:27:03 -0800
Date: Mon, 11 Feb 2019 13:26:52 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Davidlohr Bueso <dave@stgolabs.net>, netdev@vger.kernel.org,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 2/3] mm/gup: Introduce get_user_pages_fast_longterm()
Message-ID: <20190211212652.GA7790@iweiny-DESK2.sc.intel.com>
References: <20190211201643.7599-1-ira.weiny@intel.com>
 <20190211201643.7599-3-ira.weiny@intel.com>
 <20190211203916.GA2771@ziepe.ca>
 <bcc03ee1-4c42-48c3-bc67-942c0f04875e@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bcc03ee1-4c42-48c3-bc67-942c0f04875e@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 01:13:56PM -0800, John Hubbard wrote:
> On 2/11/19 12:39 PM, Jason Gunthorpe wrote:
> > On Mon, Feb 11, 2019 at 12:16:42PM -0800, ira.weiny@intel.com wrote:
> >> From: Ira Weiny <ira.weiny@intel.com>
> [...]
> >> +static inline int get_user_pages_fast_longterm(unsigned long start, int nr_pages,
> >> +					       bool write, struct page **pages)
> >> +{
> >> +	return get_user_pages_fast(start, nr_pages, write, pages);
> >> +}
> >>  #endif /* CONFIG_FS_DAX */
> >>  
> >>  int get_user_pages_fast(unsigned long start, int nr_pages, int write,
> >> @@ -2615,6 +2622,7 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
> >>  #define FOLL_REMOTE	0x2000	/* we are working on non-current tsk/mm */
> >>  #define FOLL_COW	0x4000	/* internal GUP flag */
> >>  #define FOLL_ANON	0x8000	/* don't do file mappings */
> >> +#define FOLL_LONGTERM	0x10000	/* mapping is intended for a long term pin */
> > 
> > If we are adding a new flag, maybe we should get rid of the 'longterm'
> > entry points and just rely on the callers to pass the flag?
> > 
> > Jason
> > 
> 
> +1, I agree that the overall get_user_pages*() API family will be cleaner
> *without* get_user_pages_longterm*() calls. And this new flag makes that possible.
> So I'd like to see the "longerm" call replaced with just passing this flag. Maybe
> even as part of this patchset, but either way.

Yes I've thought about this as well.  I have a couple of different versions of
this series which I've been mulling over and this was one of the other
variations.  But see below...

> 
> Taking a moment to reflect on where I think this might go eventually (the notes
> below do not need to affect your patchset here, but this seems like a good place
> to mention this):
> 
> It seems to me that the longterm vs. short-term is of questionable value.

This is exactly why I did not post this before.  I've been waiting our other
discussions on how GUP pins are going to be handled to play out.  But with the
netdev thread today[1] it seems like we need to make sure we have a "safe" fast
variant for a while.  Introducing FOLL_LONGTERM seemed like the cleanest way to
do that even if we will not need the distinction in the future...  :-(

> It's actually better to just call get_user_pages(), and then if it really is
> long-term enough to matter internally, we'll see the pages marked as gup-pinned.
> If the gup pages are released before anyone (filesystem, that is) notices, then
> it must have been short term.
> 
> Doing it that way is self-maintaining. Of course, this assumes that we end up with
> a design that doesn't require being told, by the call sites, that a given gup
> call is intended for "long term" use. So I could be wrong about this direction, but
> let's please consider the possibility.

This is why I've been holding these patches.  I'm also not 100% sure if we will
need the longterm flag in the future.

This is also why I did not change the get_user_pages_longterm because we could
be ripping this all out by the end of the year...  (I hope. :-)

So while this does "pollute" the GUP family of calls I'm hoping it is not
forever.

Ira

[1] https://lkml.org/lkml/2019/2/11/1789

> 
> thanks,
> -- 
> John Hubbard
> NVIDIA

