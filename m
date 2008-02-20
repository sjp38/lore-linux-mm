Message-ID: <47BC5C17.3070507@firstfloor.org>
Date: Wed, 20 Feb 2008 17:57:59 +0100
From: Andi Kleen <andi@firstfloor.org>
MIME-Version: 1.0
Subject: Re: [PATCH] Document huge memory/cache overhead of memory controller
 in Kconfig
References: <20080220122338.GA4352@basil.nowhere.org>	<47BC2275.4060900@linux.vnet.ibm.com> <18364.16552.455371.242369@stoffel.org>
In-Reply-To: <18364.16552.455371.242369@stoffel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Stoffel <john@stoffel.org>
Cc: balbir@linux.vnet.ibm.com, akpm@osdl.org, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I know this is a pedantic comment, but why the heck is it called such
> a generic term as "Memory Controller" which doesn't give any
> indication of what it does.

I don't think it's pedantic. I would agree with you in fact
that the Kconfig description is not very helpful, even with
my warning added.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
