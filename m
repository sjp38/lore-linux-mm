Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 991586B007E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 04:42:48 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id j8so5222653lfd.0
        for <linux-mm@kvack.org>; Tue, 10 May 2016 01:42:48 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id kl3si561480wjb.22.2016.05.10.01.42.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 May 2016 01:42:47 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id n129so1460562wmn.1
        for <linux-mm@kvack.org>; Tue, 10 May 2016 01:42:47 -0700 (PDT)
Date: Tue, 10 May 2016 10:42:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mmotm 2016-05-05-17-19 uploaded
Message-ID: <20160510084245.GF23576@dhcp22.suse.cz>
References: <572be328.fL9XliJnk212vzCy%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <572be328.fL9XliJnk212vzCy%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

On Thu 05-05-16 17:19:52, Andrew Morton wrote:
[...]
> A git tree which contains the memory management portion of this tree is
> maintained at git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
> by Michal Hocko.  It contains the patches which are between the
> "#NEXT_PATCHES_START mm" and "#NEXT_PATCHES_END" markers, from the series
> file, http://www.ozlabs.org/~akpm/mmotm/series.

JFYI, I was offline last few days so the git tree was updated only now.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
