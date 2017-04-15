Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 74BBB6B0038
	for <linux-mm@kvack.org>; Sat, 15 Apr 2017 08:19:07 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k14so11346798wrc.16
        for <linux-mm@kvack.org>; Sat, 15 Apr 2017 05:19:07 -0700 (PDT)
Received: from mail-wr0-f194.google.com (mail-wr0-f194.google.com. [209.85.128.194])
        by mx.google.com with ESMTPS id o50si7362150wrc.147.2017.04.15.05.19.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Apr 2017 05:19:06 -0700 (PDT)
Received: by mail-wr0-f194.google.com with SMTP id u18so15187430wrc.1
        for <linux-mm@kvack.org>; Sat, 15 Apr 2017 05:19:05 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: 
Date: Sat, 15 Apr 2017 14:17:31 +0200
Message-Id: <20170415121734.6692-1-mhocko@kernel.org>
In-Reply-To: <20170410110351.12215-1-mhocko@kernel.org>
References: <20170410110351.12215-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

Hi,
here I 3 more preparatory patches which I meant to send on Thursday but
forgot... After more thinking about pfn walkers I have realized that
the current code doesn't check offline holes in zones. From a quick
review that doesn't seem to be a problem currently. Pfn walkers can race
with memory offlining and with the original hotplug impementation those
offline pages can change the zone but I wasn't able to find any serious
problem other than small confusion. The new hotplug code, will not have
any valid zone, though so those code paths should check PageReserved
to rule offline holes. I hope I have addressed all of them in these 3
patches. I would appreciate if Vlastimil and Jonsoo double check after
me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
