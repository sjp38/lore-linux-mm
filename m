Message-ID: <48B30031.201@linux-foundation.org>
Date: Mon, 25 Aug 2008 13:55:45 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: oom-killer why ?
References: <48B296C3.6030706@iplabs.de> <48B2D615.4060509@linux-foundation.org> <48B2DB58.2010304@iplabs.de> <48B2DDDA.5010200@linux-foundation.org> <48B2EB37.2000200@iplabs.de>
In-Reply-To: <48B2EB37.2000200@iplabs.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marco Nietz <m.nietz-mm@iplabs.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marco Nietz wrote:
> It's should be possible to reproduce the oom, but it's a Production Server.
> 
> The oom happens after if've increased the Maximum Connections and
> Shared-Buffers for the Postgres Database Server on that Machine.
> 
> It's kernel: 2.6.18-6-686-bigmem a Debian Etch Server.

Hmmm... That should be fairly stable. I wonder how prostgres handles the
buffers? If the pages are mlocked and are required to be in lowmem then what
you saw could be related to the postgres configuration.

> And here is the Complete dmesg:


The problem is that the boot messages are cut off we cannot see the basic
operating system configuration and the hardware that was detected.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
