Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7BC176B1A1D
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 05:08:00 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id h86-v6so21025946pfd.2
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 02:08:00 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m38si38678746pgl.125.2018.11.19.02.07.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 02:07:59 -0800 (PST)
Message-ID: <1542622061.3002.6.camel@suse.de>
Subject: Re: [PATCH] mm, page_alloc: fix calculation of pgdat->nr_zones
From: osalvador <osalvador@suse.de>
Date: Mon, 19 Nov 2018 11:07:41 +0100
In-Reply-To: <20181117022022.9956-1-richard.weiyang@gmail.com>
References: <20181117022022.9956-1-richard.weiyang@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mhocko@suse.com, dave.hansen@intel.com
Cc: linux-mm@kvack.org


> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

Good catch.

One thing I was wondering is that if we also should re-adjust it when a
zone gets emptied during offlining memory.
I checked, and whenever we work wirh pgdat->nr_zones we seem to check
if the zone is populated in order to work with it.
But still, I wonder if we should re-adjust it.

Reviewed-by: Oscar Salvador <osalvador@suse.de>

Oscar Salvador
