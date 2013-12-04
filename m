Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id 114BE6B0037
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 09:56:42 -0500 (EST)
Received: by mail-yh0-f42.google.com with SMTP id z6so11518602yhz.15
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 06:56:41 -0800 (PST)
Received: from devils.ext.ti.com (devils.ext.ti.com. [198.47.26.153])
        by mx.google.com with ESMTPS id o28si7819652yhd.41.2013.12.04.06.56.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 04 Dec 2013 06:56:41 -0800 (PST)
Message-ID: <529F429D.2020207@ti.com>
Date: Wed, 4 Dec 2013 09:56:29 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 00/23] mm: Use memblock interface instead of bootmem
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com> <20131203224836.GR8277@htj.dyndns.org>
In-Reply-To: <20131203224836.GR8277@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@arm.linux.org.uk>

On Tuesday 03 December 2013 05:48 PM, Tejun Heo wrote:
> FYI, the series is missing the first patch.
> 
Patch at least made it to the list [1]. Not sure why
you didn't get it but it has your ack ;)

Regards,
Santosh

[1] https://lkml.org/lkml/2013/12/2/999

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
