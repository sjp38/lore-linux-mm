Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 981E86B007E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 10:23:35 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w143so44168677wmw.3
        for <linux-mm@kvack.org>; Mon, 16 May 2016 07:23:35 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id l124si20393478wml.71.2016.05.16.07.23.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 07:23:34 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id e201so18470277wme.2
        for <linux-mm@kvack.org>; Mon, 16 May 2016 07:23:34 -0700 (PDT)
Date: Mon, 16 May 2016 16:23:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: unhide vmstat_text definition for CONFIG_SMP
Message-ID: <20160516142332.GL23146@dhcp22.suse.cz>
References: <1462978517-2972312-1-git-send-email-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462978517-2972312-1-git-send-email-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Andrew, I think that the following is more straightforward fix and
should be folded in to the patch which has introduced vmstat_refresh.
---
