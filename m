Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 59AA76B03CB
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 16:33:24 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s82so4389047pfk.3
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 13:33:24 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q16si11631341pgn.254.2017.04.11.13.33.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 13:33:23 -0700 (PDT)
Date: Tue, 11 Apr 2017 13:33:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [HMM 10/16] mm/hmm/mirror: helper to snapshot CPU page table v2
Message-Id: <20170411133320.95086a55a1caea7fb0c58d37@linux-foundation.org>
In-Reply-To: <536509398.25054000.1491874431882.JavaMail.zimbra@redhat.com>
References: <20170405204026.3940-1-jglisse@redhat.com>
	<20170405204026.3940-11-jglisse@redhat.com>
	<20170410084326.GB4625@dhcp22.suse.cz>
	<20170410151031.d9488d850d740e894a55321c@linux-foundation.org>
	<536509398.25054000.1491874431882.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Mon, 10 Apr 2017 21:33:51 -0400 (EDT) Jerome Glisse <jglisse@redhat.com> wrote:

> > On Mon, 10 Apr 2017 10:43:26 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > > There are more for alpha allmodconfig
> > 
> > HMM is rather a compile catastrophe, as was the earlier version I
> > merged.
> > 
> > Jerome, I'm thinking you need to install some cross-compilers!
> 
> Sorry about that.
> 
> I tested some but obviously not all, in the v20 i did on top of Michal
> patchset i simply made everything to be x86-64 only. So if you revert
> v19 and wait for Michal to finish his v3 then i will post v20 that is
> x86-64 only which i do build and use. At least from my discussion with
> Michal i thought you were dropping v19 until Michal could finish his
> memory hotplug rework.

OK, I'll quietly drop the hmm series again for now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
