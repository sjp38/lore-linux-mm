Message-ID: <47BC5C99.3010008@firstfloor.org>
Date: Wed, 20 Feb 2008 18:00:09 +0100
From: Andi Kleen <andi@firstfloor.org>
MIME-Version: 1.0
Subject: Re: [PATCH] Document huge memory/cache overhead of memory controller
 in Kconfig
References: <20080220122338.GA4352@basil.nowhere.org> <47BC2275.4060900@linux.vnet.ibm.com> <18364.16552.455371.242369@stoffel.org> <47BC4554.10304@linux.vnet.ibm.com> <Pine.LNX.4.64.0802201647060.26109@fbirervta.pbzchgretzou.qr> <18364.20755.798295.881259@stoffel.org> <47BC5211.6030102@linux.vnet.ibm.com>
In-Reply-To: <47BC5211.6030102@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: John Stoffel <john@stoffel.org>, Jan Engelhardt <jengelh@computergmbh.de>, akpm@osdl.org, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> OK, I'll queue a patch and try to explain various terms used by resource management.

Don't make it too verbose or nobody will read it. It should
be more like a one paragraph abstract on a scientific paper
about the linux memory controller.

But I think it should include some variant of the warning that
was in the original patch in this thread (that could be the
second paragraph)

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
