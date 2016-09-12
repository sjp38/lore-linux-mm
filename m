Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id D05856B025E
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 07:48:59 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id k12so92712947lfb.2
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 04:48:59 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id e23si6114952wmc.77.2016.09.12.04.48.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 04:48:58 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id a6so13234527wmc.2
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 04:48:58 -0700 (PDT)
Date: Mon, 12 Sep 2016 13:48:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: split gfp_mask and mapping flags into separate
 fields
Message-ID: <20160912114852.GI14524@dhcp22.suse.cz>
References: <20160901091347.GC12147@dhcp22.suse.cz>
 <20160912111608.2588-1-mhocko@kernel.org>
 <20160912111608.2588-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160912111608.2588-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Errr, the gfp_mask move behind private_lock didn't make it into the
commit. Here is the updated patch. Btw. with this patch we can drop
mm-check-that-we-havent-used-more-than-32-bits-in-address_spaceflags.patch
---
