Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AEEBD5F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 13:16:16 -0400 (EDT)
Received: by pzk5 with SMTP id 5so155432pzk.12
        for <linux-mm@kvack.org>; Wed, 03 Jun 2009 10:16:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LFD.2.01.0906030944440.4880@localhost.localdomain>
References: <20090530192829.GK6535@oblivion.subreption.com>
	 <20090531022158.GA9033@oblivion.subreption.com>
	 <alpine.DEB.1.10.0906021130410.23962@gentwo.org>
	 <20090602203405.GC6701@oblivion.subreption.com>
	 <alpine.DEB.1.10.0906031047390.15621@gentwo.org>
	 <1244041914.12272.64.camel@localhost.localdomain>
	 <alpine.DEB.1.10.0906031134410.13551@gentwo.org>
	 <20090603162831.GF6701@oblivion.subreption.com>
	 <4A26A689.1090300@redhat.com>
	 <alpine.LFD.2.01.0906030944440.4880@localhost.localdomain>
Date: Wed, 3 Jun 2009 13:16:14 -0400
Message-ID: <7e0fb38c0906031016m77416390v37fb0673e6e50501@mail.gmail.com>
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change
	ZERO_SIZE_PTR to point at unmapped space)
From: Eric Paris <eparis@parisplace.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, "Larry H." <research@subreption.com>, Christoph Lameter <cl@linux-foundation.org>, Stephen Smalley <sds@tycho.nsa.gov>, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

On Wed, Jun 3, 2009 at 12:47 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:

> The other mistake is to think that SELinux is sane, or should be the
> default. It's a f*cking complex disaster, and makes performance plummet on
> some things.

While I think you couldn't be more wrong I'm not going to argue that topic....

I am at least interested in hearing about the 'performance plummet.'
I don't see any performance reports on my todo list but I am
interested in banging on any that people report.  Last performance
thing I heard anything about was Ingo doing some profiling of of a
network stack benchmark in which SELinux was eating a percent or two
his time.  I cut the SELinux performance penalty by about 50% on my
systems in that benchmark.  If others have complaints let me or the
selinux list know....

-Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
