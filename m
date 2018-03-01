Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2E2DD6B0003
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 18:21:46 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id d23so1661wmd.1
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 15:21:46 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i57si3559570wra.191.2018.03.01.15.21.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Mar 2018 15:21:44 -0800 (PST)
Date: Thu, 1 Mar 2018 15:21:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/page_alloc: fix memmap_init_zone pageblock alignment
Message-Id: <20180301152141.50bb01d7972806f32bbb7e62@linux-foundation.org>
In-Reply-To: <CACjP9X8hFDhkKUHRu2K5WgEp9YFHh2=vMSyM6KkZ5UZtxs7k-w@mail.gmail.com>
References: <1519908465-12328-1-git-send-email-neelx@redhat.com>
	<20180301131033.GH15057@dhcp22.suse.cz>
	<CACjP9X-S=OgmUw-WyyH971_GREn1WzrG3aeGkKLyR1bO4_pWPA@mail.gmail.com>
	<20180301152729.GM15057@dhcp22.suse.cz>
	<CACjP9X8hFDhkKUHRu2K5WgEp9YFHh2=vMSyM6KkZ5UZtxs7k-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vacek <neelx@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Pavel Tatashin <pasha.tatashin@oracle.com>, Paul Burton <paul.burton@imgtec.com>, stable@vger.kernel.org

On Thu, 1 Mar 2018 17:20:04 +0100 Daniel Vacek <neelx@redhat.com> wrote:

> Wanna me send a v2?

Yes please ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
