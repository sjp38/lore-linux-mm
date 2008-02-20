Date: Wed, 20 Feb 2008 19:28:03 +0100 (CET)
From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCH] Document huge memory/cache overhead of memory controller
 in Kconfig
In-Reply-To: <20080220181911.GA4760@ucw.cz>
Message-ID: <Pine.LNX.4.64.0802201927440.26109@fbirervta.pbzchgretzou.qr>
References: <20080220122338.GA4352@basil.nowhere.org> <47BC2275.4060900@linux.vnet.ibm.com>
 <18364.16552.455371.242369@stoffel.org> <47BC4554.10304@linux.vnet.ibm.com>
 <Pine.LNX.4.64.0802201647060.26109@fbirervta.pbzchgretzou.qr>
 <20080220181911.GA4760@ucw.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, John Stoffel <john@stoffel.org>, Andi Kleen <andi@firstfloor.org>, akpm@osdl.org, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Feb 20 2008 18:19, Pavel Machek wrote:
>> 
>> For ordinary desktop people, memory controller is what developers
>> know as MMU or sometimes even some other mysterious piece of silicon
>> inside the heavy box.
>
>Actually I'd guess 'memory controller' == 'DRAM controller' == part of
>northbridge that talks to DRAM.

Yeah that must have been it when Windows says it found a new controller
after changing the mainboard underneath.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
