Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id PAA06500
	for <linux-mm@kvack.org>; Fri, 31 Jan 2003 15:34:02 -0800 (PST)
Date: Fri, 31 Jan 2003 15:36:26 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: hugepage patches
Message-Id: <20030131153626.403ae2e1.akpm@digeo.com>
In-Reply-To: <20030131.151310.25151725.davem@redhat.com>
References: <20030131151501.7273a9bf.akpm@digeo.com>
	<20030131.151310.25151725.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"David S. Miller" <davem@redhat.com> wrote:
>
> Remind me why we can't just look at the PTE?

Diktat ;)

Linus Torvalds <torvalds@transmeta.com> wrote:
>
> ...
> Your big-page approach makes the assumption that I refuse to make - namely 
> that the "big page" is somehow attached to the page tables, and to the pmd 
> in particular.
> 
> On many architectures, big pages are totally independent of the smaller 
> pages, and don't necessarily have any of the x86 aligment/size 
> restrictions.
> 
> While on an x86, a big page is always the size of a PMD, on a ppc it can
> be any power-of-two size and alignment from 128kB to 256MB. And fixing
> that to a pmd boundary just doesn't work. They have other restrictions
> instead: they are mapped by the "BAT array", and there are 8 of those (and
> I think Linux/PPC uses a few of them for the kernel itself).
> 
> So a portable big-page approach must _not_ tie the big pages to the page
> tables. I don't like big pages particularly, but if I add big page support
> to the kernel I want to at least do it in such a way that other people
> than just Intel can use it.
> 
> Portability means that 
>  - the architecture must be able to set its large pages totally 
>    independently of the page tables. 
>  - the architecture may have other non-size-related limits on the large
>    page areas, like "only 6 large page areas can be allocated per VM"
> 
> and quite frankly, anything that goes in and mucks with the VM deeply is 
> bound to fail, I think. The patch that Intel made (with some input from 
> me) and which I attached to the previous email does this, and has almost 
> zero impact on the "normal" MM code.
> 
> 			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
