Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2322F5F000E
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:19:36 -0400 (EDT)
Date: Wed, 3 Jun 2009 09:18:22 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change
 ZERO_SIZE_PTR to point at unmapped space)
In-Reply-To: <alpine.DEB.1.10.0906031134410.13551@gentwo.org>
Message-ID: <alpine.LFD.2.01.0906030912340.4880@localhost.localdomain>
References: <20090530192829.GK6535@oblivion.subreption.com>  <alpine.LFD.2.01.0905301528540.3435@localhost.localdomain>  <20090530230022.GO6535@oblivion.subreption.com>  <alpine.LFD.2.01.0905301902010.3435@localhost.localdomain>  <20090531022158.GA9033@oblivion.subreption.com>
  <alpine.DEB.1.10.0906021130410.23962@gentwo.org>  <20090602203405.GC6701@oblivion.subreption.com>  <alpine.DEB.1.10.0906031047390.15621@gentwo.org> <1244041914.12272.64.camel@localhost.localdomain> <alpine.DEB.1.10.0906031134410.13551@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Stephen Smalley <sds@tycho.nsa.gov>, "Larry H." <research@subreption.com>, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>



On Wed, 3 Jun 2009, Christoph Lameter wrote:
> 
> mmap_min_addr depends on CONFIG_SECURITY which establishes various
> strangely complex "security models".
> 
> The system needs to be secure by default.

It _is_ secure by default. You have to do some pretty non-default things 
to get away from it.

But I do agree that it might be good to move the thing into the generic 
path. I just don't think your arguments are very good. It's not about 
defaults, it's about the fact that this isn't worth being hidden by that 
security layer.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
