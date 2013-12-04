Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f52.google.com (mail-yh0-f52.google.com [209.85.213.52])
	by kanga.kvack.org (Postfix) with ESMTP id 011DF6B003A
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 09:58:13 -0500 (EST)
Received: by mail-yh0-f52.google.com with SMTP id i72so11187271yha.25
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 06:58:13 -0800 (PST)
Received: from arroyo.ext.ti.com (arroyo.ext.ti.com. [192.94.94.40])
        by mx.google.com with ESMTPS id k26si55223430yha.79.2013.12.04.06.58.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 04 Dec 2013 06:58:13 -0800 (PST)
Message-ID: <529F42FD.5020704@ti.com>
Date: Wed, 4 Dec 2013 09:58:05 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 02/23] mm/memblock: debug: don't free reserved array
 if !ARCH_DISCARD_MEMBLOCK
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com> <1386037658-3161-3-git-send-email-santosh.shilimkar@ti.com> <20131203225258.GS8277@htj.dyndns.org>
In-Reply-To: <20131203225258.GS8277@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Tuesday 03 December 2013 05:52 PM, Tejun Heo wrote:
> On Mon, Dec 02, 2013 at 09:27:17PM -0500, Santosh Shilimkar wrote:
> ...
>> Cc: Yinghai Lu <yinghai@kernel.org>
>> Cc: Tejun Heo <tj@kernel.org>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
>> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
> 
> Reviewed-by: Tejun Heo <tj@kernel.org>
> 
>> +	/*
>> +	 * Don't allow Nobootmem allocator to free reserved memory regions
> 
> Extreme nitpick: why the capitalization of "Nobootmem"?
> 
Will fix that

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
