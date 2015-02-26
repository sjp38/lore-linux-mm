Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1ED556B0073
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 07:30:55 -0500 (EST)
Received: by wevm14 with SMTP id m14so10185597wev.8
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 04:30:54 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ed19si3004148wic.55.2015.02.26.04.30.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Feb 2015 04:30:53 -0800 (PST)
Date: Thu, 26 Feb 2015 13:30:51 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [mmotm:master 52/197] mm/cma_debug.c:71:4: error: invalid use of
 undefined type 'struct page'
Message-ID: <20150226123051.GA15187@dhcp22.suse.cz>
References: <201502261409.SlfWs6bQ%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <201502261409.SlfWs6bQ%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

I have just encoutered the same and the following patch should fix it:
---
