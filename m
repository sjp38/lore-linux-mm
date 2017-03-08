Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A4E7E831D3
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 04:18:07 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id v66so9069363wrc.4
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 01:18:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i25si3508144wrc.245.2017.03.08.01.18.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Mar 2017 01:18:06 -0800 (PST)
Date: Wed, 8 Mar 2017 10:18:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Do not use double negation for testing page flags
Message-ID: <20170308091802.GA11028@dhcp22.suse.cz>
References: <1488868597-32222-1-git-send-email-minchan@kernel.org>
 <8b5c4679-484e-fe7f-844b-af5fd41b01e0@linux.vnet.ibm.com>
 <20170308052555.GB11206@bbox>
 <6f9274f7-6d2e-60a6-c36a-78f8f79004aa@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6f9274f7-6d2e-60a6-c36a-78f8f79004aa@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, "Kirill A . Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Chen Gang <gang.chen.5i5j@gmail.com>

On Wed 08-03-17 08:51:23, Vlastimil Babka wrote:
> On 03/08/2017 06:25 AM, Minchan Kim wrote:
[...]
> > Although we can add a little description
> > somewhere in page-flags.h, I believe changing to boolean is more
> > clear/not-error-prone so Chen's work is enough worth, I think.
> 
> Agree, unless some arches benefit from the int by performance
> for some reason (no idea if it's possible).

I have a vague recollection somebody tried to change this to bool and
the resulting code was larger on some architecture. Do not remember any
details though

Btw. feel free to add
Acked-by: Michal Hocko <mhocko@suse.com>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
