Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 47D326B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 06:40:16 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w79so1634689wme.7
        for <linux-mm@kvack.org>; Wed, 31 May 2017 03:40:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w200si22067874wmw.4.2017.05.31.03.40.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 May 2017 03:40:13 -0700 (PDT)
Date: Wed, 31 May 2017 12:40:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH -v2] mm: consider memblock reservations for deferred memory
 initialization sizing
Message-ID: <20170531104010.GI27783@dhcp22.suse.cz>
References: <20170531064227.5753-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170531064227.5753-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Updated patch to fix the section mismatch warning reported by 0-day
compile bot
---
