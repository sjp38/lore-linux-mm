Subject: Re: phys-to-virt kernel mapping and ioremap()
References: <20000720174852Z156962-31297+1037@vger.rutgers.edu> <20000720183534Z156966-31297+1096@vger.rutgers.edu>
From: Jes Sorensen <jes@linuxcare.com>
Date: 20 Jul 2000 21:06:20 +0200
In-Reply-To: Timur Tabi's message of "Thu, 20 Jul 2000 13:53:05 -0500"
Message-ID: <d3wvigr58z.fsf@lxplus015.cern.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>, Linux Kernel Mailing list <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

>>>>> "Timur" == Timur Tabi <ttabi@interactivesi.com> writes:

Timur> ** Reply to message from Jes Sorensen <jes@linuxcare.com> on 20
Timur> Jul 2000 20:41:51 +0200


Timur> 1) Doesn't this mapping break the phys_to_virt and virt_to_phys
Timur> macros?
>>  Those two macros are not defined on ioremap'ed regions so it is
>> irrelevant.

Timur> In that case, how do I do virt-to-phys and phys-to-virt
Timur> translations on the memory addresses for ioremap'ed regions?

The answer is that you don't because you don't need to. You use
ioremap to mape it and you usae real/writel to access the space. You
are not allowed to treat PCI shared memory as regular memory.

Jes

PS: Please fix your mailer, it eats the References lines which is
really broken.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
