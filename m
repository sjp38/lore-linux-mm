Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 06E2A6B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 17:12:56 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id n12so4847179wgh.0
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 14:12:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id n18si7034860wij.19.2014.01.27.14.12.55
        for <linux-mm@kvack.org>;
        Mon, 27 Jan 2014 14:12:56 -0800 (PST)
Message-ID: <52E6D9D8.2060205@redhat.com>
Date: Mon, 27 Jan 2014 17:12:40 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: numa: Initialse numa balancing after jump label initialisation
References: <20140127155127.GJ4963@suse.de>
In-Reply-To: <20140127155127.GJ4963@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/27/2014 10:51 AM, Mel Gorman wrote:
> The command line parsing takes place before jump labels are initialised which
> generates a warning if numa_balancing= is specified and CONFIG_JUMP_LABEL
> is set. On older kernls before commit c4b2c0c5 (static_key: WARN on
> usage before jump_label_init was called) the kernel would have crashed.
> This patch enables automatic numa balancing later in the initialisation
> process if numa_balancing= is specified.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Cc: Stable <stable@vger.kernel.org>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
