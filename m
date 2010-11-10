Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 42CA36B0087
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 16:46:59 -0500 (EST)
Date: Wed, 10 Nov 2010 15:46:55 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: BUG: Bad page state in process (current git)
In-Reply-To: <20101110154057.GA2191@arch.trippelsdorf.de>
Message-ID: <alpine.DEB.2.00.1011101534370.30164@router.home>
References: <20101110152519.GA1626@arch.trippelsdorf.de> <20101110154057.GA2191@arch.trippelsdorf.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 10 Nov 2010, Markus Trippelsdorf wrote:

> I found this in my dmesg:
> ACPI: Local APIC address 0xfee00000
>  [ffffea0000000000-ffffea0003ffffff] PMD -> [ffff8800d0000000-ffff8800d39fffff] on node 0

That only shows you how the memmap was virtually mapped.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
