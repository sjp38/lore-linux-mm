Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BB5966001DA
	for <linux-mm@kvack.org>; Sat, 13 Feb 2010 05:24:49 -0500 (EST)
Message-ID: <4B767DD4.6090800@cs.helsinki.fi>
Date: Sat, 13 Feb 2010 12:24:20 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] [0/4] Update slab memory hotplug series
References: <20100211953.850854588@firstfloor.org>
In-Reply-To: <20100211953.850854588@firstfloor.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, rientjes@google.com
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> Should address all earlier comments (except for the funny cpuset
> case which I chose to declare a don't do that)
> 
> Also this time hopefully without missing patches.
> 
> There are still some other issues with memory hotadd, but that's the 
> current slab set.
> 
> The patches are against 2.6.32, but apply to mainline I believe.

The series has been applied and will appear in the next version of 
linux-next.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
