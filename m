Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.4 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59951C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 04:51:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11B1020896
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 04:51:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sML9I7+O"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11B1020896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FEEE6B000D; Thu, 13 Jun 2019 00:51:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AF5E6B000E; Thu, 13 Jun 2019 00:51:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 876C16B0010; Thu, 13 Jun 2019 00:51:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 533F66B000D
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 00:51:52 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id j36so12963109pgb.20
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 21:51:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=LhqXtJGGhegyYExHZ1WF6p3NXokQdCloSJ49B5IQyX0=;
        b=tATvQTe0lvNOYcV+qvVDgB7QK/DcPM5BNYwGw4drx1E427WrttiTTKCMpMw73KSBvH
         6bBaIyk8edEvxPkFLy68Yz85IhG7HN2kmAQDiKjP5+LI6nEpo+cib3cSoep87Wco3iEb
         HK6tjdEdmscadhF+OQSD1JNTgQOXTezsnJsgk5x1xmoLsJ2JRxcyLlf5zqAe7qUGILvY
         wd3Gr1/TUuG9Mvc54pLIRa9+4IW+mgezB156NowS/r4sA9QiL2Hth6hnsroahpfcc67M
         EBQ6L7/A43VpqtzkUP7Z4rtOtijJTK7sSrSNMbNz7eaVA6N/U5dzH4PDM7irNPQmzv8I
         aEWw==
X-Gm-Message-State: APjAAAUja2Sh/P1jA36+Cgp0NuBwrmU+pqha/g3W1AltF+S2APw1f2nk
	Xlm8OXFdWMk5JqDkjfWxI4QEUkX0LrVo7VQ+GozjGYD65mWaYL7HOVsVDe1lw92+u5Cu0ZQ/z4o
	Xonk/dUEO+ierQsq7VR3GyfrzJIuOwFH89nuqc++5jFaBI+5OnEdAMh40BgxyC9w=
X-Received: by 2002:a17:90a:214e:: with SMTP id a72mr3152162pje.0.1560401512040;
        Wed, 12 Jun 2019 21:51:52 -0700 (PDT)
X-Received: by 2002:a17:90a:214e:: with SMTP id a72mr3152085pje.0.1560401511384;
        Wed, 12 Jun 2019 21:51:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560401511; cv=none;
        d=google.com; s=arc-20160816;
        b=R4/c4c/bwjB5Xzvp4VDb4dLODkm38YO4P5qmd0OvNaj3T2tmsr2gQG311FEBOICFXv
         Tm1hM3NO9ycVAaqgyiXI95Mi4zVeH6yyqD0vJg31YqxvKZ628TYRzOsHPwD0vqrZLQLy
         9y0WJIE6zTS+VmL4JAOu9KttRaXQWHRkpO8gOUFzlm4OyBES1Eod51DMsBJqJHB3Uven
         ltVVjWeOttT76eIiyVbz0UnYSfEgb8Yc/Me7tr0n73bjsHfe0yxIggLZK8r9WPJRfVRa
         Jo9Wo9TGt7QRzFaY24z4cTLjK1LJ3DDSukxixtT6yRLoOp8xsabLR3eT7eFhd0suGvBt
         xtSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=LhqXtJGGhegyYExHZ1WF6p3NXokQdCloSJ49B5IQyX0=;
        b=qWEFEIKUkPnfP7W/ZBOYiRjC6X7HiRcJJ4QVNlD8h4zjnMG923x2BNWa11VhluY3il
         zj5JPYmw+jzAuYUWn31enwvEB1wuSlahg7YJC+su9lX+oXH/IptKZ4huBU/hEtP9caQ1
         Uw5KaZiMG+UjNzCCY3/6v4guOmScNr0+LxPVFz8N/04bs0Orwiy0M75Nud8aru+3zlTm
         tITAEXtYbgYM+Ufzad5hCn5Jznu22wmzna/C9lfMxaEcA/C4gdKQB1J2AYv3152U+XO7
         oMYED63LnvrBWn9OGnfTgCr9UqiFCSz1sn11ojkegCFK7iwxS2YrqnjSU5Zh560s3ouw
         Tmyw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sML9I7+O;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m2sor4577960pjl.0.2019.06.12.21.51.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 21:51:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sML9I7+O;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=LhqXtJGGhegyYExHZ1WF6p3NXokQdCloSJ49B5IQyX0=;
        b=sML9I7+Oymh+dq+TJhqSRnPXQAzZvIyyKJ7YFGVFU7zMdaMChzc0VXnA5OfDP8Qpys
         r1WVoOA6lakTBoH3eca/NE7fY9Oqs8JUafDzlGF2PDCzBIGbU0wF7y164P9gJ7Clo36S
         FMWlUk3RZRw6C18Fl2k1ikE7kH9xR8ytvYnLeRLxgw/flRUvwiCJtnU57V/+PbnPX/K/
         caSAfCjEJiSyYdmnO9Z8j+AXazpOCWoz89JzEtwOhRBniNClcb9O+qrnAdqzgPJxuYQN
         ztk1f+S1dtud0Idwd9te+HHaoRkE2EI9o1MTIOqlhbmJ0tpmJ+BVXfeNVYFO5iZDpsd/
         WiVg==
X-Google-Smtp-Source: APXvYqx3MxqqjBUhjTx2s1nicOEmErxR4OMfZE/gEbezinCYmvQK0bHgQez9jY7V95zRptnafvZHiA==
X-Received: by 2002:a17:90a:5d0a:: with SMTP id s10mr3018998pji.94.1560401510974;
        Wed, 12 Jun 2019 21:51:50 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id u23sm1266432pfn.140.2019.06.12.21.51.45
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 12 Jun 2019 21:51:49 -0700 (PDT)
Date: Thu, 13 Jun 2019 13:51:42 +0900
From: Minchan Kim <minchan@kernel.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com, lizeb@google.com
Subject: Re: [PATCH v2 0/5] Introduce MADV_COLD and MADV_PAGEOUT
Message-ID: <20190613045142.GG55602@google.com>
References: <20190610111252.239156-1-minchan@kernel.org>
 <21cf2918-ba0e-aae1-a20e-36ee1ad4f704@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <21cf2918-ba0e-aae1-a20e-36ee1ad4f704@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 10, 2019 at 11:03:00AM -0700, Dave Hansen wrote:
> I'd really love to see the manpages for these new flags.  The devil is
> in the details of our promises to userspace.

I'm waiting comments from reviewers since I have fixed what they point
out from the previous version.

I will add manpage material in respin after the getting more feedback.
Thanks.

