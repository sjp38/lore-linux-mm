Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8DE316B00D8
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:41:29 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E53C882CB25
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:56:14 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id hxttfsc1NGjl for <linux-mm@kvack.org>;
	Wed,  3 Jun 2009 11:56:14 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 22FA982CCCC
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:56:04 -0400 (EDT)
Date: Wed, 3 Jun 2009 11:41:12 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change
 ZERO_SIZE_PTR to point at unmapped space)
In-Reply-To: <1244041914.12272.64.camel@localhost.localdomain>
Message-ID: <alpine.DEB.1.10.0906031134410.13551@gentwo.org>
References: <20090530192829.GK6535@oblivion.subreption.com>  <alpine.LFD.2.01.0905301528540.3435@localhost.localdomain>  <20090530230022.GO6535@oblivion.subreption.com>  <alpine.LFD.2.01.0905301902010.3435@localhost.localdomain>  <20090531022158.GA9033@oblivion.subreption.com>
  <alpine.DEB.1.10.0906021130410.23962@gentwo.org>  <20090602203405.GC6701@oblivion.subreption.com>  <alpine.DEB.1.10.0906031047390.15621@gentwo.org> <1244041914.12272.64.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Stephen Smalley <sds@tycho.nsa.gov>
Cc: "Larry H." <research@subreption.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

On Wed, 3 Jun 2009, Stephen Smalley wrote:

> > If one remaps page 0 then the kernel checks for NULL pointers of various
> > flavors are bypassed and this may be exploited in various creative ways
> > to transfer data from kernel space to user space.
> >
> > Fix this by not allowing the remapping of page 0. Return -EINVAL if
> > such a mapping is attempted.
>
> You can already prevent unauthorized processes from mapping low memory
> via the existing mmap_min_addr setting, configurable via
> SECURITY_DEFAULT_MMAP_MIN_ADDR or /proc/sys/vm/mmap_min_addr.  Then
> cap_file_mmap() or selinux_file_mmap() will apply a check when a process
> attempts to map memory below that address.

mmap_min_addr depends on CONFIG_SECURITY which establishes various
strangely complex "security models".

The system needs to be secure by default.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
