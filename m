Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id C6A7B6B0390
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 17:22:52 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id w34so15355439qtw.17
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 14:22:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n22si2500250qkh.134.2017.04.06.14.22.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Apr 2017 14:22:52 -0700 (PDT)
Date: Thu, 6 Apr 2017 17:22:47 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 14/16] mm/hmm/devmem: device memory hotplug using
 ZONE_DEVICE
Message-ID: <20170406212247.GA4723@redhat.com>
References: <20170405204026.3940-1-jglisse@redhat.com>
 <20170405204026.3940-15-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="ZPt4rx8FFjLCG7dd"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170405204026.3940-15-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>


--ZPt4rx8FFjLCG7dd
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit


So during rebase on lastest mmotm one if branch logic got inversed.
Attached is a fixup patch.

Cheers,
Jerome

--ZPt4rx8FFjLCG7dd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-fixup-mm-hmm-devmem-device-memory-hotplug-using-ZONE.patch"


--ZPt4rx8FFjLCG7dd--
