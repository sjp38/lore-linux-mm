Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id D72B96B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 03:59:07 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so21185394pdb.0
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 00:59:07 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id z5si38297179pdo.233.2015.04.29.00.59.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Apr 2015 00:59:07 -0700 (PDT)
Date: Wed, 29 Apr 2015 10:58:53 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH v3 0/3] idle memory tracking
Message-ID: <20150429075853.GC1694@esperanza>
References: <cover.1430217477.git.vdavydov@parallels.com>
 <20150429035722.GA11486@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150429035722.GA11486@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Minchan,

Thank you for taking a look at this patch set.

On Wed, Apr 29, 2015 at 12:57:22PM +0900, Minchan Kim wrote:
> On Tue, Apr 28, 2015 at 03:24:39PM +0300, Vladimir Davydov wrote:
> >  * /proc/kpageidle.  For each page this file contains a 64-bit number, which
> >    equals 1 if the page is idle or 0 otherwise, indexed by PFN. A page is
> 
> Why do we need 64bit per page to indicate just idle or not?

I don't think we need this, actually. I made this file 64 bit per page
only to conform to other /proc/kpage* files. Currently, I can't think of
any potential use for residual 63 bits, so personally I'm fine with 1
bit per page. If nobody comes with an idea about how > 1 bits could be
used, I'll switch /proc/kpageidle to a bitmask in the next iteration.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
