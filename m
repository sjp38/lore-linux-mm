Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 288666B0035
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 13:29:20 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kp14so9311437pab.6
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 10:29:19 -0700 (PDT)
Message-ID: <1381857934.26234.99.camel@misato.fc.hp.com>
Subject: Re: [PATCH 1/2] mm: Set N_CPU to node_states during boot
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 15 Oct 2013 11:25:34 -0600
In-Reply-To: <00000141bd24292a-c0ebad11-c3bb-441e-a58e-e17b3bc2e21c-000000@email.amazonses.com>
References: <1381857176-22999-1-git-send-email-toshi.kani@hp.com>
	 <1381857176-22999-2-git-send-email-toshi.kani@hp.com>
	 <00000141bd24292a-c0ebad11-c3bb-441e-a58e-e17b3bc2e21c-000000@email.amazonses.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com

On Tue, 2013-10-15 at 17:22 +0000, Christoph Lameter wrote:
> On Tue, 15 Oct 2013, Toshi Kani wrote:
> 
> > Changed setup_vmstat() to mark N_CPU to the nodes with
> > online CPUs at boot, which is consistent with other
> > operations in vmstat_cpuup_callback(), i.e. start_cpu_timer()
> > and refresh_zone_stat_thresholds().
> 
> Acked-by: Christoph Lameter <cl@linux.com>

Thanks Christoph for the quick review to the patchset!
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
