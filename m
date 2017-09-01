Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0E0526B0292
	for <linux-mm@kvack.org>; Fri,  1 Sep 2017 05:34:15 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id t138so3057633wmt.7
        for <linux-mm@kvack.org>; Fri, 01 Sep 2017 02:34:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v76si1722229wmv.93.2017.09.01.02.34.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Sep 2017 02:34:13 -0700 (PDT)
Date: Fri, 1 Sep 2017 11:34:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mmotm 2017-08-31-16-13 uploaded
Message-ID: <20170901093411.j63pltbizc67qqs2@dhcp22.suse.cz>
References: <59a8982c.FwLJY62HB+esikOu%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <59a8982c.FwLJY62HB+esikOu%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

On Thu 31-08-17 16:13:48, Andrew Morton wrote:
[...]
> A git tree which contains the memory management portion of this tree is
> maintained at git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
> by Michal Hocko.  It contains the patches which are between the
> "#NEXT_PATCHES_START mm" and "#NEXT_PATCHES_END" markers, from the series
> file, http://www.ozlabs.org/~akpm/mmotm/series.

The tree has been updated. I am just travelling and forgot my USB with
the signing key so the current tree is not signed. The top commit is
94f3eacbd387f09e5ec07433e8e9e2cd7bcf3105
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
