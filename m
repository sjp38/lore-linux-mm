Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 152426B000D
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 05:39:11 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id j17-v6so443933wrm.11
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 02:39:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j4-v6sor5474459wmd.21.2018.10.10.02.39.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 02:39:09 -0700 (PDT)
Date: Wed, 10 Oct 2018 11:39:08 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v3 2/3] mm: return zero_resv_unavail optimization
Message-ID: <20181010093908.GA20663@techadventures.net>
References: <20181002143821.5112-1-msys.mizuma@gmail.com>
 <20181002143821.5112-3-msys.mizuma@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181002143821.5112-3-msys.mizuma@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masayoshi Mizuma <msys.mizuma@gmail.com>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Michal Hocko <mhocko@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org

On Tue, Oct 02, 2018 at 10:38:20AM -0400, Masayoshi Mizuma wrote:
> From: Pavel Tatashin <pavel.tatashin@microsoft.com>
> 
> When checking for valid pfns in zero_resv_unavail(), it is not necessary to
> verify that pfns within pageblock_nr_pages ranges are valid, only the first
> one needs to be checked. This is because memory for pages are allocated in
> contiguous chunks that contain pageblock_nr_pages struct pages.
> 
> Signed-off-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
> Reviewed-by: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
> Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Looks good to me 

Reviewed-by: Oscar Salvador <osalvador@suse.de>

Thanks
-- 
Oscar Salvador
SUSE L3
