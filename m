Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id D754A6B03FB
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 04:31:37 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id x137so6585295lff.3
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 01:31:37 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id t1si604223lja.28.2017.04.06.01.31.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Apr 2017 01:31:36 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id v2so3035223lfi.2
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 01:31:35 -0700 (PDT)
Date: Thu, 6 Apr 2017 11:31:32 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 1/4] mm: memcontrol: clean up memory.events counting
 function
Message-ID: <20170406083132.GA2268@esperanza>
References: <20170404220148.28338-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170404220148.28338-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Apr 04, 2017 at 06:01:45PM -0400, Johannes Weiner wrote:
> We only ever count single events, drop the @nr parameter. Rename the
> function accordingly. Remove low-information kerneldoc.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
