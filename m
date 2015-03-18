Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9C1CF6B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 12:14:10 -0400 (EDT)
Received: by wibg7 with SMTP id g7so66508242wib.1
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 09:14:10 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wh5si29711952wjb.85.2015.03.18.09.14.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Mar 2015 09:14:09 -0700 (PDT)
Date: Wed, 18 Mar 2015 17:14:07 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH -v2] mm, memcg: sync allocation and memcg charge gfp flags
 for THP
Message-ID: <20150318161407.GP17241@dhcp22.suse.cz>
References: <1426514892-7063-1-git-send-email-mhocko@suse.cz>
 <55098D0A.8090605@suse.cz>
 <20150318150257.GL17241@dhcp22.suse.cz>
 <55099C72.1080102@suse.cz>
 <20150318155905.GO17241@dhcp22.suse.cz>
 <5509A31C.3070108@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5509A31C.3070108@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Updated version
---
