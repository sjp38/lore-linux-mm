Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D52345F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:47:44 -0400 (EDT)
Date: Wed, 3 Jun 2009 09:47:23 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change
 ZERO_SIZE_PTR to point at unmapped space)
In-Reply-To: <4A26A689.1090300@redhat.com>
Message-ID: <alpine.LFD.2.01.0906030944440.4880@localhost.localdomain>
References: <20090530192829.GK6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301528540.3435@localhost.localdomain> <20090530230022.GO6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301902010.3435@localhost.localdomain> <20090531022158.GA9033@oblivion.subreption.com>
 <alpine.DEB.1.10.0906021130410.23962@gentwo.org> <20090602203405.GC6701@oblivion.subreption.com> <alpine.DEB.1.10.0906031047390.15621@gentwo.org> <1244041914.12272.64.camel@localhost.localdomain> <alpine.DEB.1.10.0906031134410.13551@gentwo.org>
 <20090603162831.GF6701@oblivion.subreption.com> <4A26A689.1090300@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: "Larry H." <research@subreption.com>, Christoph Lameter <cl@linux-foundation.org>, Stephen Smalley <sds@tycho.nsa.gov>, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>



On Wed, 3 Jun 2009, Rik van Riel wrote:
> 
> Would anybody paranoid run their system without SELinux?

You make two very fundamental mistakes.

The first is to assume that this is about "paranoid" people. Security is 
_not_ about people who care deeply about security. It's about everybody. 
Look at viruses and DDoS attacks - the "paranoid" people absolutely depend 
on the _non_paranoid people being secure too!

The other mistake is to think that SELinux is sane, or should be the 
default. It's a f*cking complex disaster, and makes performance plummet on 
some things. I turn it off, and I know lots of other sane people do too. 
So the !SElinux case really does need to work.

				Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
