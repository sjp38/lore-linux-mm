Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 852BF6B0007
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 20:47:56 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id o33-v6so8116895plb.16
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 17:47:56 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m1-v6si1423577plk.577.2018.04.09.17.47.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 17:47:55 -0700 (PDT)
Date: Mon, 9 Apr 2018 17:47:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm] mm, pagemap: Fix swap offset value for PMD
 migration entry
Message-Id: <20180409174753.4b959a5b3ff732b8f96f5a14@linux-foundation.org>
In-Reply-To: <20180408033737.10897-1-ying.huang@intel.com>
References: <20180408033737.10897-1-ying.huang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrei Vagin <avagin@openvz.org>, Dan Williams <dan.j.williams@intel.com>, Jerome Glisse <jglisse@redhat.com>, Daniel Colascione <dancol@google.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Sun,  8 Apr 2018 11:37:37 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:

> From: Huang Ying <ying.huang@intel.com>
> 
> The swap offset reported by /proc/<pid>/pagemap may be not correct for
> PMD migration entry.  If addr passed into pagemap_range() isn't

pagemap_pmd_range(), yes?

> aligned with PMD start address,

How can this situation come about?

> the swap offset reported doesn't
> reflect this.  And in the loop to report information of each sub-page,
> the swap offset isn't increased accordingly as that for PFN.
> 
> BTW: migration swap entries have PFN information, do we need to
> restrict whether to show them?

For what reason?  Address obfuscation?
