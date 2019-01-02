Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6A58D8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 18:00:50 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id m37so40274270qte.10
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 15:00:50 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id z64si257424qke.271.2019.01.02.15.00.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 15:00:49 -0800 (PST)
Date: Wed, 2 Jan 2019 15:00:54 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [v4 PATCH 1/2] mm: swap: check if swap backing device is
 congested or not
Message-ID: <20190102230054.m5ire5gdhm5fzecq@ca-dmjordan1.us.oracle.com>
References: <1546145375-793-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1546145375-793-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: ying.huang@intel.com, tim.c.chen@intel.com, minchan@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Dec 30, 2018 at 12:49:34PM +0800, Yang Shi wrote:
> The test on my virtual machine with congested HDD shows long tail
> latency is reduced significantly.
> 
> Without the patch
>  page_fault1_thr-1490  [023]   129.311706: funcgraph_entry:      #57377.796 us |  do_swap_page();
>  page_fault1_thr-1490  [023]   129.369103: funcgraph_entry:        5.642us   |  do_swap_page();
>  page_fault1_thr-1490  [023]   129.369119: funcgraph_entry:      #1289.592 us |  do_swap_page();
>  page_fault1_thr-1490  [023]   129.370411: funcgraph_entry:        4.957us   |  do_swap_page();
>  page_fault1_thr-1490  [023]   129.370419: funcgraph_entry:        1.940us   |  do_swap_page();
>  page_fault1_thr-1490  [023]   129.378847: funcgraph_entry:      #1411.385 us |  do_swap_page();
>  page_fault1_thr-1490  [023]   129.380262: funcgraph_entry:        3.916us   |  do_swap_page();
>  page_fault1_thr-1490  [023]   129.380275: funcgraph_entry:      #4287.751 us |  do_swap_page();
> 
> With the patch
>       runtest.py-1417  [020]   301.925911: funcgraph_entry:      #9870.146 us |  do_swap_page();
>       runtest.py-1417  [020]   301.935785: funcgraph_entry:        9.802us   |  do_swap_page();
>       runtest.py-1417  [020]   301.935799: funcgraph_entry:        3.551us   |  do_swap_page();
>       runtest.py-1417  [020]   301.935806: funcgraph_entry:        2.142us   |  do_swap_page();
>       runtest.py-1417  [020]   301.935853: funcgraph_entry:        6.938us   |  do_swap_page();
>       runtest.py-1417  [020]   301.935864: funcgraph_entry:        3.765us   |  do_swap_page();
>       runtest.py-1417  [020]   301.935871: funcgraph_entry:        3.600us   |  do_swap_page();
>       runtest.py-1417  [020]   301.935878: funcgraph_entry:        7.202us   |  do_swap_page();

Hi Yang, I guess runtest.py just calls page_fault1_thr?  Being explicit about
this may improve the changelog for those unfamiliar with will-it-scale.

May also be useful to name will-it-scale and how it was run (#thr, runtime,
system cpus/memory/swap) for more context.
