Message-ID: <48B403D7.4020404@linux-foundation.org>
Date: Tue, 26 Aug 2008 08:23:35 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: oom-killer why ?
References: <48B296C3.6030706@iplabs.de> <48B2D615.4060509@linux-foundation.org> <48B2DB58.2010304@iplabs.de> <48B2DDDA.5010200@linux-foundation.org> <48B2EB37.2000200@iplabs.de> <48B30031.201@linux-foundation.org> <48B3A656.4000902@iplabs.de>
In-Reply-To: <48B3A656.4000902@iplabs.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marco Nietz <m.nietz-mm@iplabs.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marco Nietz wrote:
>
> It's a Dell Poweredge 1950, Dual Quad Core with 2.66GHz and 16G Ram. The
> Machine has two Raid-Controllers. One used for the OS and the other one
> for a Direct Attached Storage (MD-3000). This Storage is controlled with
> multipath-tools and used for Database Storage.

I'd strongly suggest to go to 64 bit for that machine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
