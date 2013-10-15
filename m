Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id EAF086B0038
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 13:23:04 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id r10so9182026pdi.0
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 10:23:04 -0700 (PDT)
Date: Tue, 15 Oct 2013 17:23:00 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] mm: Clear N_CPU from node_states at CPU offline
In-Reply-To: <1381857176-22999-3-git-send-email-toshi.kani@hp.com>
Message-ID: <00000141bd246468-e388da5e-d7ba-4428-9374-9b37ca59b92c-000000@email.amazonses.com>
References: <1381857176-22999-1-git-send-email-toshi.kani@hp.com> <1381857176-22999-3-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com

On Tue, 15 Oct 2013, Toshi Kani wrote:

> vmstat_cpuup_callback() is a CPU notifier callback, which
> marks N_CPU to a node at CPU online event.  However, it
> does not update this N_CPU info at CPU offline event.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
