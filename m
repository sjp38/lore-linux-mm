Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3B2D18D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 04:09:17 -0500 (EST)
Date: Thu, 17 Feb 2011 10:09:10 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in
 2.6.38-rc4
Message-ID: <20110217090910.GA3781@tiehlicka.suse.cz>
References: <20110216185234.GA11636@tiehlicka.suse.cz>
 <20110216193700.GA6377@elte.hu>
 <AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com>
 <AANLkTi=xnbcs5BKj3cNE_aLtBO7W5m+2uaUacu7M8g_S@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTi=xnbcs5BKj3cNE_aLtBO7W5m+2uaUacu7M8g_S@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 16-02-11 12:09:35, Linus Torvalds wrote:
> On Wed, Feb 16, 2011 at 11:50 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > Yup, goodie. It does look like it might be exactly the same thing,
> > except now the offset seems to be 0x1e68 instead of 0x1768.
> 
> It was 0x1748 in Eric's case. Background for Michal:
> 
>   http://lkml.org/lkml/2011/2/14/223

I have seen that thread but I didn't think it is related. I thought
this is an another anon_vma issue. But you seem to be right that the
offset pattern can be related.

> 
> Michal - if you can re-create this, it would be wonderful if you can
> enable CONFIG_DEBUG_PAGEALLOC. I didn't find any obvious candidates
> yet.

OK. I have just booted with the same kernel and the config turned on.
Let's see if I am able to reproduce.

Btw.
$ objdump -d ./vmlinux-2.6.38-rc4-00001-g07409af-vmscan-test | grep 0x1e68

didn't print out anything. Do you have any other way to find out the
structure?
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
