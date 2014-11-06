Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id BF4CE6B0085
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 04:08:50 -0500 (EST)
Received: by mail-lb0-f175.google.com with SMTP id n15so539879lbi.6
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 01:08:49 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p6si10489957lap.91.2014.11.06.01.08.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 01:08:47 -0800 (PST)
Date: Thu, 6 Nov 2014 10:08:45 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [mmotm:master 143/283] mm/slab.c:3260:4: error: implicit
 declaration of function 'slab_free'
Message-ID: <20141106090845.GA17744@dhcp22.suse.cz>
References: <201411060959.OFpcU713%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <201411060959.OFpcU713%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi,
I have encountered the same error as well. We need to move the forward
declaration up outside of CONFIG_NUMA:
---
