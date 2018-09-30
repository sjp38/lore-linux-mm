Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id BC1118E0001
	for <linux-mm@kvack.org>; Sun, 30 Sep 2018 04:17:10 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id l8-v6so7696368wme.6
        for <linux-mm@kvack.org>; Sun, 30 Sep 2018 01:17:10 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 65-v6si5714845wmw.37.2018.09.30.01.17.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 30 Sep 2018 01:17:09 -0700 (PDT)
Date: Sun, 30 Sep 2018 10:17:04 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [LKP] [mm/swap]  d884021f52:  will-it-scale.per_process_ops
 -2.4% regression
Message-ID: <20180930081704.ncajd6rv23qnv237@linutronix.de>
References: <20180914145924.22055-2-bigeasy@linutronix.de>
 <20180930031640.GG15893@shao2-debian>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180930031640.GG15893@shao2-debian>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel test robot <rong.a.chen@intel.com>
Cc: linux-mm@kvack.org, tglx@linutronix.de, Vlastimil Babka <vbabka@suse.cz>, frederic@kernel.org, lkp@01.org

On 2018-09-30 11:16:41 [+0800], kernel test robot wrote:
> Greeting,
> 
> FYI, we noticed a -2.4% regression of will-it-scale.per_process_ops due to commit:
> 
> 
> commit: d884021f52609407c7943705b3e54b1642fa10cb ("[PATCH 1/2] mm/swap: Add pagevec locking")

-2.4% regression reads to me like an improvement of 2.4%. Which is odd
because I wouldn't expect a change in behaviour from 1/2. 2/2 yes, under
certain workloads but not from 1/2.

Sebastian
