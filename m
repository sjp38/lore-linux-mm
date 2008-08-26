Message-ID: <48B3A656.4000902@iplabs.de>
Date: Tue, 26 Aug 2008 08:44:38 +0200
From: Marco Nietz <m.nietz-mm@iplabs.de>
MIME-Version: 1.0
Subject: Re: oom-killer why ?
References: <48B296C3.6030706@iplabs.de> <48B2D615.4060509@linux-foundation.org> <48B2DB58.2010304@iplabs.de> <48B2DDDA.5010200@linux-foundation.org> <48B2EB37.2000200@iplabs.de> <48B30031.201@linux-foundation.org>
In-Reply-To: <48B30031.201@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter schrieb:

> Hmmm... That should be fairly stable. I wonder how prostgres handles the
> buffers? If the pages are mlocked and are required to be in lowmem then what
> you saw could be related to the postgres configuration.

Don't know it exactly, but will try to find it out. And yes, the Machine
was fairly stable until i raised up shared buffers.

> The problem is that the boot messages are cut off we cannot see the basic
> operating system configuration and the hardware that was detected.

Haven't got more Information than the ones if've posted, sorry-

Maybe this short Overview helps:

It's a Dell Poweredge 1950, Dual Quad Core with 2.66GHz and 16G Ram. The
Machine has two Raid-Controllers. One used for the OS and the other one
for a Direct Attached Storage (MD-3000). This Storage is controlled with
multipath-tools and used for Database Storage.


Best Regards
Marco



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
