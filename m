Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 06D256B0260
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 09:46:45 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id v125so92173049itc.0
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 06:46:45 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id 197si1424633iou.38.2016.06.02.06.46.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 06:46:44 -0700 (PDT)
Date: Thu, 2 Jun 2016 08:46:42 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/4] mm/vmstat: remove unused header cpumask.h
In-Reply-To: <866efd744a89b6e16c9d3acd1a00b011adbd59af.1464847139.git.geliangtang@gmail.com>
Message-ID: <alpine.DEB.2.20.1606020845310.32179@east.gentwo.org>
References: <7cc1b41351a96e7d67fcf4bd2a6987b71793cb27.1464847139.git.geliangtang@gmail.com> <866efd744a89b6e16c9d3acd1a00b011adbd59af.1464847139.git.geliangtang@gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 2 Jun 2016, Geliang Tang wrote:

> Remove unused header cpumask.h from mm/vmstat.c.

cpu.h by necessity already includes cpumask.h. So I guess its ok.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
