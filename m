Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8B8E86B025E
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 18:25:37 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id z128so237012530pfb.4
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 15:25:37 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z70si8171pff.228.2017.01.09.15.25.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jan 2017 15:25:36 -0800 (PST)
Date: Mon, 9 Jan 2017 15:27:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] memory_hotplug: zone_can_shift() returns boolean
 value
Message-Id: <20170109152703.4dd336106200d55d8f4deafb@linux-foundation.org>
In-Reply-To: <2f9c3837-33d7-b6e5-59c0-6ca4372b2d84@gmail.com>
References: <2f9c3837-33d7-b6e5-59c0-6ca4372b2d84@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, Reza Arbab <arbab@linux.vnet.ibm.com>

On Tue, 13 Dec 2016 15:29:49 -0500 Yasuaki Ishimatsu <yasu.isimatu@gmail.com> wrote:

> online_{kernel|movable} is used to change the memory zone to
> ZONE_{NORMAL|MOVABLE} and online the memory.
> 
> To check that memory zone can be changed, zone_can_shift() is used.
> Currently the function returns minus integer value, plus integer
> value and 0. When the function returns minus or plus integer value,
> it means that the memory zone can be changed to ZONE_{NORNAL|MOVABLE}.
> 
> But when the function returns 0, there is 2 meanings.
> 
> One of the meanings is that the memory zone does not need to be changed.
> For example, when memory is in ZONE_NORMAL and onlined by online_kernel
> the memory zone does not need to be changed.
> 
> Another meaning is that the memory zone cannot be changed. When memory
> is in ZONE_NORMAL and onlined by online_movable, the memory zone may
> not be changed to ZONE_MOVALBE due to memory online limitation(see
> Documentation/memory-hotplug.txt). In this case, memory must not be
> onlined.
> 
> The patch changes the return type of zone_can_shift() so that memory
> is not onlined when memory zone cannot be changed.

What are the user-visible runtime effects of this fix?

Please always include this info when fixing bugs - it is required so
that others can decide which kernel version(s) need the fix.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
