Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 39DA36B0035
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 13:22:49 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb12so1161591pbc.36
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 10:22:48 -0700 (PDT)
Date: Tue, 15 Oct 2013 17:22:45 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] mm: Set N_CPU to node_states during boot
In-Reply-To: <1381857176-22999-2-git-send-email-toshi.kani@hp.com>
Message-ID: <00000141bd24292a-c0ebad11-c3bb-441e-a58e-e17b3bc2e21c-000000@email.amazonses.com>
References: <1381857176-22999-1-git-send-email-toshi.kani@hp.com> <1381857176-22999-2-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com

On Tue, 15 Oct 2013, Toshi Kani wrote:

> Changed setup_vmstat() to mark N_CPU to the nodes with
> online CPUs at boot, which is consistent with other
> operations in vmstat_cpuup_callback(), i.e. start_cpu_timer()
> and refresh_zone_stat_thresholds().

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
