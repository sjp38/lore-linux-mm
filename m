Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 199F08E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 06:03:32 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id b3so2825652edi.0
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 03:03:32 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m4si541011edi.384.2019.01.09.03.03.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 03:03:30 -0800 (PST)
Date: Wed, 9 Jan 2019 12:03:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/2] oom, memcg: do not report racy no-eligible OOM
Message-ID: <20190109110328.GS31793@dhcp22.suse.cz>
References: <20190107143802.16847-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190107143802.16847-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Tetsuo,
can you confirm that these two patches are fixing the issue you have
reported please?
-- 
Michal Hocko
SUSE Labs
