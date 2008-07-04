Message-ID: <486E28AE.1020801@firstfloor.org>
Date: Fri, 04 Jul 2008 15:42:06 +0200
From: Andi Kleen <andi@firstfloor.org>
MIME-Version: 1.0
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
References: <1215093175.10393.567.camel@pmac.infradead.org>	 <20080703173040.GB30506@mit.edu>	 <1215111362.10393.651.camel@pmac.infradead.org>	 <20080703.162120.206258339.davem@davemloft.net>	 <486D6DDB.4010205@infradead.org>  <87ej6armez.fsf@basil.nowhere.org> <1215177044.10393.743.camel@pmac.infradead.org>
In-Reply-To: <1215177044.10393.743.camel@pmac.infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: David Miller <davem@davemloft.net>, tytso@mit.edu, jeff@garzik.org, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> No, not even in the initramfs. It's built _right_ into the static kernel
> image, and request_firmware() finds it there without even having to call
> out to userspace at all.

Great. Thanks.

-Andi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
