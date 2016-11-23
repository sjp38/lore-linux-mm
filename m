Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A0C426B0273
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 04:30:57 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y68so9564703pfb.6
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:30:57 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id q204si32829615pfq.242.2016.11.23.01.30.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Nov 2016 01:30:56 -0800 (PST)
Date: Wed, 23 Nov 2016 12:30:53 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] mm: fix false-positive WARN_ON() in truncate/invalidate
 for hugetlb
Message-ID: <20161123093053.mjbnvn5zwxw5e6lk@black.fi.intel.com>
References: <20161123092326.169822-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161123092326.169822-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Doug Nelson <doug.nelson@intel.com>, "[4.8+]" <stable@vger.kernel.org>

Sorry, forgot to commit local changes.

----8<----
