Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB51E2806CB
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 08:52:46 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id k87so123686117ioi.3
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 05:52:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 2si10307798pla.226.2017.04.21.05.52.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 21 Apr 2017 05:52:42 -0700 (PDT)
Date: Fri, 21 Apr 2017 14:52:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 10/13] mm, memory_hotplug: do not associate hotadded
 memory to zones until online
Message-ID: <20170421125235.GF14154@dhcp22.suse.cz>
References: <20170421120512.23960-1-mhocko@kernel.org>
 <20170421123003.25937-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170421123003.25937-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

In case you were wondering about the weird sorting. git send-email has
failed while at patch10 so I had to repost it and so the patch is out of
order. It should be still applied as 10th patch.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
