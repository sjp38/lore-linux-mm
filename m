Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 895D06B0033
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 17:38:13 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id t84so142433215qke.7
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 14:38:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d48si2378447qtc.41.2017.01.10.14.38.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jan 2017 14:38:12 -0800 (PST)
Date: Tue, 10 Jan 2017 17:38:09 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: [LSF/MM TOPIC] HMM, CDM and other infrastructure for device memory
 management
Message-ID: <20170110223808.GC3342@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, John Hubbard <jhubbard@nvidia.com>, Serguei Sagalovitch <serguei.sagalovitch@amd.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

So if the schedule of mm track still has room i would like to discuss further
where we are in respect to device memory management and HMM as well as other
technology like CDM/ATS/CCIX/CAPI. I think this is becoming a pressing issue
and i would like to discuss about how we want to address all this.

People that would be important to this discussion:
"Anshuman Khandual" <khandual@linux.vnet.ibm.com>
"John Hubbard" <jhubbard@nvidia.com>
"Serguei Sagalovitch" <serguei.sagalovitch@amd.com>
"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

I am most likely missing people here.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
