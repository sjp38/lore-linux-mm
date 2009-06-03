Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1AF0C6B00DC
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:29:34 -0400 (EDT)
Date: Wed, 3 Jun 2009 09:28:44 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change
 ZERO_SIZE_PTR to point at unmapped space)
In-Reply-To: <7e0fb38c0906030922u3af8c2abi8a2cfdcd66151a5a@mail.gmail.com>
Message-ID: <alpine.LFD.2.01.0906030925480.4880@localhost.localdomain>
References: <20090530192829.GK6535@oblivion.subreption.com>  <20090530230022.GO6535@oblivion.subreption.com>  <alpine.LFD.2.01.0905301902010.3435@localhost.localdomain>  <20090531022158.GA9033@oblivion.subreption.com>  <alpine.DEB.1.10.0906021130410.23962@gentwo.org>
  <20090602203405.GC6701@oblivion.subreption.com>  <alpine.DEB.1.10.0906031047390.15621@gentwo.org>  <alpine.LFD.2.01.0906030800490.4880@localhost.localdomain>  <alpine.DEB.1.10.0906031121030.15621@gentwo.org>  <alpine.LFD.2.01.0906030827580.4880@localhost.localdomain>
 <7e0fb38c0906030922u3af8c2abi8a2cfdcd66151a5a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric Paris <eparis@parisplace.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, "Larry H." <research@subreption.com>, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>



On Wed, 3 Jun 2009, Eric Paris wrote:
> 
> As I recall the only need for CONFIG_SECURITY is for the ability to
> override the check.

No, if you have SECURITY disabled entirely, the check goes away.

If you have SECURITY on, but then use the simple capability model, the 
check is there.

If you have SECURITY on, and then use SElinux, you can make it be dynamic.

> I think I could probably pretty cleanly change it to use
> CAP_SYS_RAWIO/SELinux permissions if CONFIG_SECURITY and just allow it
> for uid=0 in the non-security case?

We probably should, since the "capability" security version should 
generally essentially emulate the regular non-SECURITY case for root. 

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
