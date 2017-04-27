Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 32CAC6B03A4
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 03:58:30 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id q91so2356222wrb.8
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 00:58:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w43si1843265wrc.260.2017.04.27.00.58.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Apr 2017 00:58:29 -0700 (PDT)
Date: Thu, 27 Apr 2017 09:58:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 07/13] mm: consider zone which is not fully populated to
 have holes
Message-ID: <20170427075825.GB4706@dhcp22.suse.cz>
References: <20170421120512.23960-1-mhocko@kernel.org>
 <20170421120512.23960-8-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170421120512.23960-8-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

I plan to fold the following into this patch.
---
