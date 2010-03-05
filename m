Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3995E6B004D
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 00:34:39 -0500 (EST)
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id o255Yb7E023810
	for <linux-mm@kvack.org>; Thu, 4 Mar 2010 21:34:37 -0800
Received: from pzk41 (pzk41.prod.google.com [10.243.19.169])
	by spaceape11.eur.corp.google.com with ESMTP id o255YF5j000914
	for <linux-mm@kvack.org>; Thu, 4 Mar 2010 21:34:36 -0800
Received: by pzk41 with SMTP id 41so2237315pzk.23
        for <linux-mm@kvack.org>; Thu, 04 Mar 2010 21:34:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <49b004811003042117n720f356h7e10997a1a783475@mail.gmail.com>
References: <49b004811003041321g2567bac8yb73235be32a27e7c@mail.gmail.com>
	<20100305032106.GA12065@cmpxchg.org> <49b004811003042117n720f356h7e10997a1a783475@mail.gmail.com>
From: Greg Thelen <gthelen@google.com>
Date: Thu, 4 Mar 2010 21:34:14 -0800
Message-ID: <49b004811003042134s4bbd0425n1517a1cb0e9879d9@mail.gmail.com>
Subject: Re: mmotm boot panic bootmem-avoid-dma32-zone-by-default.patch
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Yinghai Lu <yinghai@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 4, 2010 at 9:17 PM, Greg Thelen <gthelen@google.com> wrote:
> On Thu, Mar 4, 2010 at 7:21 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
>> 256MB of memory, right?
>
> yes, I am testing in a 256MB VM.

I also performed a 6GB test and found that the system booted fine with
defconfig:
CONFIG_NO_BOOTMEM=y
CONFIG_SPARSEMEM_EXTREME=y

--
Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
