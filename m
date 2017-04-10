Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D6E976B0390
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 18:10:34 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e20so37056695pfb.10
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 15:10:34 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t10si14752154plh.309.2017.04.10.15.10.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 15:10:34 -0700 (PDT)
Date: Mon, 10 Apr 2017 15:10:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [HMM 10/16] mm/hmm/mirror: helper to snapshot CPU page table v2
Message-Id: <20170410151031.d9488d850d740e894a55321c@linux-foundation.org>
In-Reply-To: <20170410084326.GB4625@dhcp22.suse.cz>
References: <20170405204026.3940-1-jglisse@redhat.com>
	<20170405204026.3940-11-jglisse@redhat.com>
	<20170410084326.GB4625@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Mon, 10 Apr 2017 10:43:26 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> There are more for alpha allmodconfig

HMM is rather a compile catastrophe, as was the earlier version I
merged.

Jerome, I'm thinking you need to install some cross-compilers!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
