Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 22E455F0001
	for <linux-mm@kvack.org>; Sat, 30 May 2009 19:02:48 -0400 (EDT)
Date: Sat, 30 May 2009 16:00:22 -0700
From: "Larry H." <research@subreption.com>
Subject: Re: [PATCH] Change ZERO_SIZE_PTR to point at unmapped space
Message-ID: <20090530230022.GO6535@oblivion.subreption.com>
References: <20090530192829.GK6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301528540.3435@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.01.0905301528540.3435@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 15:29 Sat 30 May     , Linus Torvalds wrote:
> 
> 
> On Sat, 30 May 2009, Larry H. wrote:
> > 
> > The ZERO_OR_NULL_PTR macro is changed accordingly. This patch does
> > not modify its behavior nor has any performance nor functionality
> > impact.
> 
> I'm sure it makes a code generation difference, with (a) big constants and 
> (b) no longer possible to merge the conditional into one single one.

Like I said in the reply to Peter, this is 3 extra bytes for amd64 with
gcc 4.3.3. I can't be bothered to check other architectures at the
moment.

	Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
