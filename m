Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7B13C6B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 06:33:37 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id a10so2000746pgq.3
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 03:33:37 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 76si1126490pgd.240.2017.11.29.03.33.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Nov 2017 03:33:36 -0800 (PST)
Date: Wed, 29 Nov 2017 12:33:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH RFC v2 2/2] mm, hugetlb: do not rely on overcommit limit
 during migration
Message-ID: <20171129113330.znjgwtviw6tr6npo@dhcp22.suse.cz>
References: <20171128101907.jtjthykeuefxu7gl@dhcp22.suse.cz>
 <20171128141211.11117-1-mhocko@kernel.org>
 <20171128141211.11117-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171128141211.11117-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>

OK, so this is the v2 with all the fixups folded in. It doesn't blow up
immediately and even seem to work.
---
