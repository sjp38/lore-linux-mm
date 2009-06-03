Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4526C5F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:36:45 -0400 (EDT)
Message-ID: <4A26A689.1090300@redhat.com>
Date: Wed, 03 Jun 2009 12:36:25 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change	ZERO_SIZE_PTR
 to point at unmapped space)
References: <20090530192829.GK6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301528540.3435@localhost.localdomain> <20090530230022.GO6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301902010.3435@localhost.localdomain> <20090531022158.GA9033@oblivion.subreption.com> <alpine.DEB.1.10.0906021130410.23962@gentwo.org> <20090602203405.GC6701@oblivion.subreption.com> <alpine.DEB.1.10.0906031047390.15621@gentwo.org> <1244041914.12272.64.camel@localhost.localdomain> <alpine.DEB.1.10.0906031134410.13551@gentwo.org> <20090603162831.GF6701@oblivion.subreption.com>
In-Reply-To: <20090603162831.GF6701@oblivion.subreption.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Stephen Smalley <sds@tycho.nsa.gov>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

Larry H. wrote:

> Christopher, crippling the system is truly not the way to fix this.
> There are many legitimate users of private|fixed mappings at 0. In
> addition, if you want to go ahead and break POSIX, at least make sure
> your patch closes the loophole.

I suspect there aren't many at all, and restricting them through
SELinux may be enough to mitigate the risk.

> If SELinux isn't present, that's not useful. If mmap_min_addr is
> enabled, that still won't solve what my original, utterly simple patch
> fixes.

Would anybody paranoid run their system without SELinux?

> The patch provides a no-impact, clean solution to prevent kmalloc(0)
> situations from becoming a security hazard. Nothing else.

True, the changes in your patch only affect a few code paths.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
