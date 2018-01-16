Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9393F28024A
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 16:30:14 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id d25so11092060otc.1
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 13:30:14 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k27si1296384ote.380.2018.01.16.13.30.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 13:30:12 -0800 (PST)
Date: Tue, 16 Jan 2018 16:30:08 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: [LSF/MM TOPIC] HMM status upstream user what's next, mmu_notifier
Message-ID: <20180116213008.GC8801@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, David Rientjes <rientjes@google.com>, John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>

I want to talk about status of HMM and respective upstream user for
it and also talk about what's next in term of features/improvement
plan (generic page write protection, mmu_notifier, ...). Most likely
short 15-30minutes if mmu_notifier is split into its own topic.

I want to talk about mmu_notifier, specificaly adding more context
information to mmu_notifier callback (why a notification is happening
reclaim, munmap, migrate, ...). Maybe we can grow this into its own
topic and talk about mmu_notifier and issue with it like OOM or being
able to sleep/take lock ... and improving mitigation.

People (mmu_notifier probably interest a larger set):
    "Anshuman Khandual" <khandual@linux.vnet.ibm.com>
    "Balbir Singh" <bsingharora@gmail.com>
    "David Rientjes" <rientjes@google.com>
    "John Hubbard" <jhubbard@nvidia.com>
    "Michal Hocko" <mhocko@suse.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
