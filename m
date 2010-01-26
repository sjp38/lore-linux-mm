Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 451066B0099
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 18:53:58 -0500 (EST)
Message-ID: <4B5F7F53.8060002@nortel.com>
Date: Tue, 26 Jan 2010 17:48:35 -0600
From: "Chris Friesen" <cfriesen@nortel.com>
MIME-Version: 1.0
Subject: Re: which fields in /proc/meminfo are orthogonal?
References: <4B5F3C9C.3050908@nortel.com> <4B5F54DE.7030302@nortel.com>
In-Reply-To: <4B5F54DE.7030302@nortel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 01/26/2010 02:47 PM, Chris Friesen wrote:

> I've tried adding up
> MemFree+Buffers+Cached+AnonPages+Mapped+Slab+PageTables+VmallocUsed
> 
> (hugepages are disabled and there is no swap)
> 
> Shortly after boot this gets me within about 3MB of MemTotal.  However,
> after 1070 minutes there is a 64MB difference between MemTotal and the
> above sum.

Oddly enough, over the same period it appears that

MemFree + Active + Inactive + Slab + PageTables

is basically (+/- half a meg) constant and equal to "MemTotal - 48.5MB".


It would seem that active/inactive track memory that isn't visible in
Buffers+Cached+AnonPages+Mapped.  Anyone have any suggestions what it
might be?

Thanks,

Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
