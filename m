Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9A560831F4
	for <linux-mm@kvack.org>; Fri, 19 May 2017 03:22:28 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u96so3304504wrc.7
        for <linux-mm@kvack.org>; Fri, 19 May 2017 00:22:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 128si8942542wmd.74.2017.05.19.00.22.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 00:22:27 -0700 (PDT)
Date: Fri, 19 May 2017 09:22:25 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [mmotm:master 61/139] include/asm-generic/memory_model.h:54:52:
 warning: 'page' is used uninitialized in this function
Message-ID: <20170519072225.GA13041@dhcp22.suse.cz>
References: <201705190738.Nkd5Ar0X%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201705190738.Nkd5Ar0X%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, kbuild test robot <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>

Ups, sorry about that. Andrew could you fold the following into
mm-vmstat-skip-reporting-offline-pages-in-pagetypeinfo.patch
---
