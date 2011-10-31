Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6876C6B006E
	for <linux-mm@kvack.org>; Mon, 31 Oct 2011 14:34:32 -0400 (EDT)
Date: Mon, 31 Oct 2011 19:34:23 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
Message-ID: <20111031183423.GG3466@redhat.com>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org>
 <1319785956.3235.7.camel@lappy>
 <CAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>
 <CAOJsxLEE-qf9me1SAZLFiEVhHVnDh7BDrSx1+abe9R4mfkhD=g@mail.gmail.com20111028163053.GC1319@redhat.com>
 <b86860d2-3aac-4edd-b460-bd95cb1103e6@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b86860d2-3aac-4edd-b460-bd95cb1103e6@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Johannes Weiner <jweiner@redhat.com>, Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Hugh Dickins <hughd@google.com>

On Fri, Oct 28, 2011 at 10:07:12AM -0700, Dan Magenheimer wrote:
> First, there are several companies and several unaffiliated kernel
> developers contributing here, building on top of frontswap.  I happen
> to be spearheading it, and my company is backing me up.  (It
> might be more appropriate to note that much of the resistance comes
> from people of your company... but please let's keep our open-source
> developer hats on and have a technical discussion rather than one
> which pleases our respective corporate overlords.)

Fair enough to want an independent review but I'd be interesting to
also know how many of the several companies and unaffiliated kernel
developers are contributing to it that aren't using tmem with
Xen. Obviously bounce buffers 4k vmexits are still faster than
Xen-paravirt-I/O on disk platter...

Note, Hugh is working for another company... and they're using cgroups
not KVM nor Xen, so I suggests he'd be a fair reviewer from a non-virt
standpoint, if he hopefully has the time to weight in.

However keep in mind if we'd see something that can allow KVM to run
even faster, we'd be quite silly in not taking advantage of it too, to
beat our own SPECvirt record. The whole design idea of KVM (unlike
Xen) is to reuse the kernel improvements as much as possible so when
the guest runs faster the hypervisor also runs faster with the exact
same code. Problem a vmexit doing a bounce buffer every 4k doesn't mix
well into SPECvirt in my view and that probably is what has kept us
from making any attempt to use tmem API anywhere.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
