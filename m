Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 234E46B0253
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 09:39:55 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id 43so1207166pla.17
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 06:39:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l20si1342989pgn.808.2017.12.13.06.39.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Dec 2017 06:39:53 -0800 (PST)
Date: Wed, 13 Dec 2017 15:39:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/3] mm, numa: rework do_pages_move
Message-ID: <20171213143948.GM25185@dhcp22.suse.cz>
References: <20171207143401.GK20234@dhcp22.suse.cz>
 <20171208161559.27313-1-mhocko@kernel.org>
 <20171208161559.27313-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171208161559.27313-2-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Reale <ar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>

This patch has been generated with --patience parameter as suggested by
Kirill and it realy seems to provide a more compact diff.
---
