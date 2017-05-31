Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6307B6B02F3
	for <linux-mm@kvack.org>; Wed, 31 May 2017 12:04:29 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g143so3882987wme.13
        for <linux-mm@kvack.org>; Wed, 31 May 2017 09:04:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g200si19591002wmg.53.2017.05.31.09.04.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 May 2017 09:04:27 -0700 (PDT)
Date: Wed, 31 May 2017 18:04:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: strange PAGE_ALLOC_COSTLY_ORDER usage in xgbe_map_rx_buffer
Message-ID: <20170531160422.GW27783@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Tom,
I have stumbled over the following construct in xgbe_map_rx_buffer
	order = max_t(int, PAGE_ALLOC_COSTLY_ORDER - 1, 0);
which looks quite suspicious. Why does it PAGE_ALLOC_COSTLY_ORDER - 1?
And why do you depend on PAGE_ALLOC_COSTLY_ORDER at all?

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
