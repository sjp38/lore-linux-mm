Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 269D48E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 12:15:58 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id t13so34279459ioi.3
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 09:15:58 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id k143si295931itb.43.2019.01.03.09.15.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 09:15:57 -0800 (PST)
Date: Thu, 3 Jan 2019 09:16:02 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [v4 PATCH 1/2] mm: swap: check if swap backing device is
 congested or not
Message-ID: <20190103171602.frjmcagwwqtzwqka@ca-dmjordan1.us.oracle.com>
References: <1546145375-793-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190102230054.m5ire5gdhm5fzecq@ca-dmjordan1.us.oracle.com>
 <76d8727a-77b4-d476-af89-9ae1904ec8cd@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <76d8727a-77b4-d476-af89-9ae1904ec8cd@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, ying.huang@intel.com, tim.c.chen@intel.com, minchan@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jan 03, 2019 at 09:10:13AM -0800, Yang Shi wrote:
> How about the below description:
> 
> The test with page_fault1 of will-it-scale (sometimes tracing may just show
> runtest.py that is the wrapper script of page_fault1), which basically
> launches NR_CPU threads to generate 128MB anonymous pages for each thread,�
> on my virtual machine with congested HDD shows long tail latency is reduced
> significantly.
> 
> Without the patch
> �page_fault1_thr-1490� [023]�� 129.311706: funcgraph_entry: #57377.796 us |�
> do_swap_page();
> �page_fault1_thr-1490� [023]�� 129.369103: funcgraph_entry: 5.642us�� |�
> do_swap_page();
> �page_fault1_thr-1490� [023]�� 129.369119: funcgraph_entry: #1289.592 us |�
> do_swap_page();
> �page_fault1_thr-1490� [023]�� 129.370411: funcgraph_entry: 4.957us�� |�
> do_swap_page();
> �page_fault1_thr-1490� [023]�� 129.370419: funcgraph_entry: 1.940us�� |�
> do_swap_page();
> �page_fault1_thr-1490� [023]�� 129.378847: funcgraph_entry: #1411.385 us |�
> do_swap_page();
> �page_fault1_thr-1490� [023]�� 129.380262: funcgraph_entry: 3.916us�� |�
> do_swap_page();
> �page_fault1_thr-1490� [023]�� 129.380275: funcgraph_entry: #4287.751 us |�
> do_swap_page();
> 
> With the patch
> ����� runtest.py-1417� [020]�� 301.925911: funcgraph_entry: #9870.146 us |�
> do_swap_page();
> ����� runtest.py-1417� [020]�� 301.935785: funcgraph_entry: 9.802us�� |�
> do_swap_page();
> ����� runtest.py-1417� [020]�� 301.935799: funcgraph_entry: 3.551us�� |�
> do_swap_page();
> ����� runtest.py-1417� [020]�� 301.935806: funcgraph_entry: 2.142us�� |�
> do_swap_page();
> ����� runtest.py-1417� [020]�� 301.935853: funcgraph_entry: 6.938us�� |�
> do_swap_page();
> ����� runtest.py-1417� [020]�� 301.935864: funcgraph_entry: 3.765us�� |�
> do_swap_page();
> ����� runtest.py-1417� [020]�� 301.935871: funcgraph_entry: 3.600us�� |�
> do_swap_page();
> ����� runtest.py-1417� [020]�� 301.935878: funcgraph_entry: 7.202us�� |�
> do_swap_page();

That's better, thanks!
