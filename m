Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 948968D0039
	for <linux-mm@kvack.org>; Wed, 16 Feb 2011 15:13:51 -0500 (EST)
Date: Wed, 16 Feb 2011 21:13:42 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in
 2.6.38-rc4
Message-ID: <20110216201342.GA7766@elte.hu>
References: <20110216185234.GA11636@tiehlicka.suse.cz>
 <20110216193700.GA6377@elte.hu>
 <AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Wed, Feb 16, 2011 at 11:37 AM, Ingo Molnar <mingo@elte.hu> wrote:
> >
> > ( Cc:-ed Linus - he was analyzing a similar looking bug a few days ago on lkml.
> >  Mail repeated below. )
> 
> Yup, goodie. It does look like it might be exactly the same thing,
> except now the offset seems to be 0x1e68 instead of 0x1768.
> 
> I'll compile a x86-32 kernel with that config and try to see if I can
> find that offset in there..

Michal, you might also want to try to find it - in case Linus's different compiler 
somehow hides that offset.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
