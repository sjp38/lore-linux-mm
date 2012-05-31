Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 6C8DC6B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 18:54:20 -0400 (EDT)
Date: Fri, 1 Jun 2012 00:54:06 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: AutoNUMA15
Message-ID: <20120531225406.GQ21339@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
 <20120529133627.GA7637@shutemov.name>
 <20120529154308.GA10790@dhcp-27-244.brq.redhat.com>
 <20120531180834.GP21339@redhat.com>
 <4FC7CE0F.9070706@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FC7CE0F.9070706@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Don Morris <don.morris@hp.com>
Cc: linux-mm@kvack.org

Hi Don,

On Thu, May 31, 2012 at 01:01:19PM -0700, Don Morris wrote:
> We're a special pte, but a non-zero pfn. Being Xorg, I'm
> assuming this is a remap of a kernel page into the user virtual
> address space, but that's just a gut instinct. Since I read

I reproduced it. The address is in /dev/mem, the other is a nonlinear
ext4 map.

> the above as "We don't expect to ever take spurious faults
> on instantiated special ptes", I would think you'd need

I would better skip VM_PFNMAP|VM_MIXEDMAP agreed, but it still
shouldn't fail like this, vma_normal_page shouldn't error out on a
pte_special.

> Of course... I'm still really ramping up on this kernel, so
> that could all be hokum, too. Hopefully it helps.

It helps a lot, thanks!

> I can dump the EFI memory map and whatnot to you if you
> need it, but I think this is more of an algorithmic issue

No need, I can reproduce.

On the bright side, it looks totally harmless and you can ignore it.

And if you run "echo 0 >/sys/kernel/mm/autonuma/knuma_scand/pmd" it
seems to go away but I suggest to keep the default and ignore it, the
pmd scan saves 1% of the overhead.

I'll push a fix in the origin/autonuma branch as soon as I figure it
out...

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
