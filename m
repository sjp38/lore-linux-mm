Subject: Re: [PATCH] ppc64: Fix possible race with set_pte on a present PTE
Message-ID: <OFB228E20C.FF1B818B-ONC1256EA6.004258F7-C1256EA6.0042EA55@de.ibm.com>
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Date: Tue, 1 Jun 2004 14:10:53 +0200
MIME-Version: 1.0
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, bcrl@kvack.org, "David S. Miller" <davem@redhat.com>, Linux Arch list <linux-arch@vger.kernel.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, mingo@elte.hu, Linus Torvalds <torvalds@osdl.org>, wesolows@foobazco.org, willy@debian.org
List-ID: <linux-mm.kvack.org>




> I did the ppc64 impl, the x86 one (hope I got it right). I still need to
> do ppc32 and I suppose s390 must be fixed now that ptep_estabish is gone
> but I'll leave that to someone who understand something about these
things ;)

At the moment I can't access linux.bkbits.net so I can't test anything but
as far as I can tell s390 should just work as is. ptep_establish is gone
but it has been replaced by correct sequences: ptep_clear_flush & set_pte
and set_pte & flush_tlb_page. The second sequence can be optimized to a
ptep_clear_flush & set_pte if the _PAGE_RO bit has changed. Apart from
that s390 is perfectly fine with the change.

blue skies,
   Martin

Linux/390 Design & Development, IBM Deutschland Entwicklung GmbH
Schonaicherstr. 220, D-71032 Boblingen, Telefon: 49 - (0)7031 - 16-2247
E-Mail: schwidefsky@de.ibm.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
