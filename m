Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 58FC66B0388
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 06:57:36 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id u9so9693836wme.6
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 03:57:36 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f48si6179284wra.120.2017.03.16.03.57.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Mar 2017 03:57:35 -0700 (PDT)
Date: Thu, 16 Mar 2017 11:57:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] mm: page_alloc: Fix misordered logging output,
 reduce code size
Message-ID: <20170316105733.GC30508@dhcp22.suse.cz>
References: <cover.1489628459.git.joe@perches.com>
 <2aaf6f1701ee78582743d91359018689d5826e82.1489628459.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2aaf6f1701ee78582743d91359018689d5826e82.1489628459.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 15-03-17 18:43:14, Joe Perches wrote:
> When CONFIG_TRANSPARENT_HUGEPAGE is set, there is an output defect
> where the values emitted do not match the textual descriptions.

please separate this out to one patch without all other changes.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
