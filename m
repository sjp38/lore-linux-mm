Date: Sun, 30 Mar 2008 21:06:14 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH 8/8] x86_64: Support for new UV apic
Message-ID: <20080331020613.GA20619@sgi.com>
References: <20080328191216.GA16455@sgi.com> <86802c440803301622j2874ca56t51b52a54920a233b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <86802c440803301622j2874ca56t51b52a54920a233b@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Cc: Andi Kleen <ak@suse.de>, mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> so this is "the new one of Friday"?

Yes, and it has the same bug although it is located
in a slightly different place.

A few minutes ago, I posted a patch to delete the extra lines.


> Did you test it on non UV_X2APIC box?

The code is clearly wrong.  I booted on an 8p AMD box and
had no problems. Apparently the kernel (at least basic booting) is
not too sensitive to incorrect apicids being returned. Most
critical-to-boot code must use apicids from the ACPI tables.
However, the bug does affect numa node assignment. And probably
other places, too.


--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
