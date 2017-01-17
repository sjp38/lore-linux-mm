Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3034F6B0260
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 15:31:45 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 204so69425952pge.5
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 12:31:45 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id h91si18552574pld.68.2017.01.17.12.31.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 12:31:44 -0800 (PST)
From: "Chen, Tim C" <tim.c.chen@intel.com>
Subject: RE: [Update][PATCH v5 7/9] mm/swap: Add cache for swap slots
 allocation
Date: Tue, 17 Jan 2017 20:31:27 +0000
Message-ID: <045D8A5597B93E4EBEDDCBF1FC15F50935C9FB53@fmsmsx104.amr.corp.intel.com>
References: <cover.1484082593.git.tim.c.chen@linux.intel.com>
 <35de301a4eaa8daa2977de6e987f2c154385eb66.1484082593.git.tim.c.chen@linux.intel.com>
 <87tw8ymm2z.fsf_-_@yhuang-dev.intel.com>
 <20170117101631.GG19699@dhcp22.suse.cz>
 <045D8A5597B93E4EBEDDCBF1FC15F50935C9F523@fmsmsx104.amr.corp.intel.com>
 <20170117200338.GA26217@dhcp22.suse.cz>
In-Reply-To: <20170117200338.GA26217@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Hansen, Dave" <dave.hansen@intel.com>, "ak@linux.intel.com" <ak@linux.intel.com>, "Lu, Aaron" <aaron.lu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>

> > >
> >
> > The cache->slots_ret  is protected by cache->free_lock and
> > cache->slots is protected by cache->free_lock.

Typo.  cache->slots is protected by cache->alloc_lock.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
