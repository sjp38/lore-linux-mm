Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f174.google.com (mail-ea0-f174.google.com [209.85.215.174])
	by kanga.kvack.org (Postfix) with ESMTP id DCA9A6B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 01:57:47 -0500 (EST)
Received: by mail-ea0-f174.google.com with SMTP id b10so3520859eae.33
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 22:57:47 -0800 (PST)
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com. [195.75.94.110])
        by mx.google.com with ESMTPS id k3si1927850eep.78.2014.01.20.22.57.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jan 2014 22:57:46 -0800 (PST)
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <phacht@linux.vnet.ibm.com>;
	Tue, 21 Jan 2014 06:57:46 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 86CD81B08069
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 06:57:07 +0000 (GMT)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0L6vUdJ40108274
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 06:57:30 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0L6vfvB000490
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 23:57:42 -0700
Date: Tue, 21 Jan 2014 07:57:38 +0100
From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Subject: Re: [PATCH V5 1/3] mm/nobootmem: Fix unused variable
Message-ID: <20140121075738.771d29b3@lilie>
In-Reply-To: <alpine.DEB.2.02.1401202214540.21729@chino.kir.corp.google.com>
References: <1390217559-14691-1-git-send-email-phacht@linux.vnet.ibm.com>
	<1390217559-14691-2-git-send-email-phacht@linux.vnet.ibm.com>
	<alpine.DEB.2.02.1401202214540.21729@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, liuj97@gmail.com, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, iamjoonsoo.kim@lge.com, robin.m.holt@gmail.com, tangchen@cn.fujitsu.com, yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



Am Mon, 20 Jan 2014 22:16:33 -0800 (PST)
schrieb David Rientjes <rientjes@google.com>:

> Not sure why you don't just do a one line patch:
> 
> -	phys_addr_t size;
> +	phys_addr_t size __maybe_unused;
> to fix it.

Just because I did not know that __maybe_unused thing.

Discussion of this fix seems to be obsolete because Andrew already took
the patch int the form he suggested: One #ifdef in the function with a
basic block declaring size once inside.

Regards

Philipp

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
