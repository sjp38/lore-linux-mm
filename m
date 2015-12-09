Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3F2336B0257
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 04:07:39 -0500 (EST)
Received: by wmvv187 with SMTP id v187so250583109wmv.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 01:07:38 -0800 (PST)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id y30si10735573wmh.97.2015.12.09.01.07.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 01:07:37 -0800 (PST)
Received: by wmvv187 with SMTP id v187so250582509wmv.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 01:07:37 -0800 (PST)
Date: Wed, 9 Dec 2015 10:07:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH mmotm] memcg: Ignore partial THP when moving task
Message-ID: <20151209090735.GA30907@dhcp22.suse.cz>
References: <1449594789-15866-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1449594789-15866-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Dohh, forgot to git add after s@PageCoumpound@PageTransCompound@
Updated patch is below:
---
