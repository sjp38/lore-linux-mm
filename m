Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f170.google.com (mail-ea0-f170.google.com [209.85.215.170])
	by kanga.kvack.org (Postfix) with ESMTP id 179786B0035
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 08:54:27 -0500 (EST)
Received: by mail-ea0-f170.google.com with SMTP id k10so844114eaj.29
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 05:54:27 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v6si93348287eel.196.2014.01.08.05.54.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 05:54:22 -0800 (PST)
Date: Wed, 8 Jan 2014 14:54:22 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: could you clarify mm/mempolicy: fix !vma in new_vma_page()
Message-ID: <20140108135422.GJ27937@dhcp22.suse.cz>
References: <CAA_GA1dNdrG9aQ3UKDA0O=BY721rvseORVkc2+RxUpzysp3rYw@mail.gmail.com>
 <20140106141827.GB27602@dhcp22.suse.cz>
 <CAA_GA1csMEhSYmeS7qgDj7h=Xh2WrsYvirkS55W4Jj3LTHy87A@mail.gmail.com>
 <20140107102212.GC8756@dhcp22.suse.cz>
 <20140107173034.GE8756@dhcp22.suse.cz>
 <CAA_GA1fN5p3-m40Mf3nqFzRrGcJ9ni9Cjs_q4fm1PCLnzW1cEw@mail.gmail.com>
 <20140108100859.GC27937@dhcp22.suse.cz>
 <CAA_GA1emcHt+9zOqAKHPoXLd-ofyfYyuQn9fcdLOox5k7BLgww@mail.gmail.com>
 <20140108124240.GH27937@dhcp22.suse.cz>
 <CAA_GA1dh3TtzGnK0HgAb_Sy6ww5JBaFqmf_YViPKpMCEpzFh4w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA_GA1dh3TtzGnK0HgAb_Sy6ww5JBaFqmf_YViPKpMCEpzFh4w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bob Liu <bob.liu@oracle.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Bob Liu <lliubbo@gmail.com>

Hi Andrew,
the whole thread started here: http://lkml.org/lkml/2014/1/6/217
I guess it makes sense to revert part of the already merged commit with
the following patch. If the BUG_ON triggers again then we should rather
find out why page_address_in_vma fails on anon_vma or f_mapping checks
and not simply paper over it.
---
