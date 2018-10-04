Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 273F86B026D
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 03:45:00 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c13-v6so2774534ede.6
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 00:45:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m15-v6si238261ejq.215.2018.10.04.00.44.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 00:44:59 -0700 (PDT)
Date: Thu, 4 Oct 2018 09:44:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/3] Randomize free memory
Message-ID: <20181004074457.GD22173@dhcp22.suse.cz>
References: <153861931865.2863953.11185006931458762795.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153861931865.2863953.11185006931458762795.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Dave Hansen <dave.hansen@linux.intel.com>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 03-10-18 19:15:18, Dan Williams wrote:
> Changes since v1:
> * Add support for shuffling hot-added memory (Andrew)
> * Update cover letter and commit message to clarify the performance impact
>   and relevance to future platforms

I believe this hasn't addressed my questions in
http://lkml.kernel.org/r/20181002143015.GX18290@dhcp22.suse.cz. Namely
"
It is the more general idea that I am not really sure about. First of
all. Does it make _any_ sense to randomize 4MB blocks by default? Why
cannot we simply have it disabled? Then and more concerning question is,
does it even make sense to have this randomization applied to higher
orders than 0? Attacker might fragment the memory and keep recycling the
lowest order and get the predictable behavior that we have right now.
"

> [1]: https://lkml.org/lkml/2018/9/15/366
-- 
Michal Hocko
SUSE Labs
