Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id B3E2B6B0003
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 02:06:47 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id w18-v6so545222plp.3
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 23:06:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x5-v6si513807pgg.75.2018.07.25.23.06.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 23:06:45 -0700 (PDT)
Date: Thu, 26 Jul 2018 08:06:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Re: [PATCH] [PATCH] mm: disable preemption before swapcache_free
Message-ID: <20180726060640.GQ28386@dhcp22.suse.cz>
References: <2018072514375722198958@wingtech.com>
 <20180725141643.6d9ba86a9698bc2580836618@linux-foundation.org>
 <2018072610214038358990@wingtech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2018072610214038358990@wingtech.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "zhaowuyun@wingtech.com" <zhaowuyun@wingtech.com>
Cc: akpm <akpm@linux-foundation.org>, mgorman <mgorman@techsingularity.net>, minchan <minchan@kernel.org>, vinmenon <vinmenon@codeaurora.org>, hannes <hannes@cmpxchg.org>, "hillf.zj" <hillf.zj@alibaba-inc.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

On Thu 26-07-18 10:21:40, zhaowuyun@wingtech.com wrote:
[...]
> Our project really needs a fix to this issue

Could you be more specific why? My understanding is that RT tasks
usually have all the memory mlocked otherwise all the real time
expectations are gone already.
-- 
Michal Hocko
SUSE Labs
