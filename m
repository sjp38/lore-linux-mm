Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9C9BA6B1A34
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 08:48:39 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id 34-v6so23472301plf.6
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 05:48:39 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id v189si38253742pgb.398.2018.11.19.05.48.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 05:48:38 -0800 (PST)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH RESEND 0/2] free order-0 pages through PCP in page_frag_free() and cleanup
Date: Mon, 19 Nov 2018 21:48:32 +0800
Message-Id: <20181119134834.17765-1-aaron.lu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?q?Pawe=C5=82=20Staszewski?= <pstaszewski@itcare.pl>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, Yoel Caspersen <yoel@kviknet.dk>, Mel Gorman <mgorman@techsingularity.net>, Saeed Mahameed <saeedm@mellanox.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Ian Kumlien <ian.kumlien@gmail.com>

This is a resend of the two patches.

Patch 1 is the same as:
[PATCH v2 1/2] mm/page_alloc: free order-0 pages through PCP in page_frag_free()
https://lkml.kernel.org/r/20181106052833.GC6203@intel.com
With one more ack from Tariq Toukan.

Patch 2 is the same as:
[PATCH v3 2/2] mm/page_alloc: use a single function to free page
https://lkml.kernel.org/r/20181106113149.GC24198@intel.com
With some changelog rewording.

Applies on top of v4.20-rc2-mmotm-2018-11-16-14-52.

Aaron Lu (2):
  mm/page_alloc: free order-0 pages through PCP in page_frag_free()
  mm/page_alloc: use a single function to free page

 mm/page_alloc.c | 29 +++++++++++++----------------
 1 file changed, 13 insertions(+), 16 deletions(-)

-- 
2.17.2
