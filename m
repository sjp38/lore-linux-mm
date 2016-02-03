Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 36DB66B0005
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 07:16:49 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id p63so67381157wmp.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 04:16:49 -0800 (PST)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id k5si9589729wjf.120.2016.02.03.04.16.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 04:16:48 -0800 (PST)
Received: by mail-wm0-f50.google.com with SMTP id p63so67380456wmp.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 04:16:47 -0800 (PST)
Date: Wed, 3 Feb 2016 13:16:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mmotm 2016-02-02-17-08 uploaded
Message-ID: <20160203121646.GE6757@dhcp22.suse.cz>
References: <56b1532f.mwdov6KmWTCFuZoC%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56b1532f.mwdov6KmWTCFuZoC%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org


On Tue 02-02-16 17:09:03, Andrew Morton wrote:
> A git tree which contains the memory management portion of this tree is
> maintained at git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
> by Michal Hocko.  It contains the patches which are between the
> "#NEXT_PATCHES_START mm" and "#NEXT_PATCHES_END" markers, from the series
> file, http://www.ozlabs.org/~akpm/mmotm/series.

JFYI DAX changes are really hard to track properly because there are
some changes coming from different trees, the code changes permanently
and it is really hard to see what is the current base so I have skipped
those fixes which depend on the code which is outside of mmotm patches +
linus tree.

If you want to develop for DAX or something that might clash there
please use linux-next instead.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
