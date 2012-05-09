Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 9AEDC6B00F0
	for <linux-mm@kvack.org>; Wed,  9 May 2012 09:08:07 -0400 (EDT)
Date: Wed, 9 May 2012 09:07:58 -0400
From: Ted Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] Documentations: Fix slabinfo.c directory in vm/slub.txt
Message-ID: <20120509130758.GD6773@thunk.org>
References: <201205031634316254497@gmail.com>
 <201205091439545464323@gmail.com>
 <CAHGf_=rU1UUvtcEoyabos08vE0o8diwXoRmekCfH=vi_r0inpA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHGf_=rU1UUvtcEoyabos08vE0o8diwXoRmekCfH=vi_r0inpA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: majianpeng <majianpeng@gmail.com>, Pekka Enberg <penberg@kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>

On Wed, May 09, 2012 at 04:13:02AM -0400, KOSAKI Motohiro wrote:
> 
> I guess because almost lkml chinese guys use different custom. e.g.
> Wu Fengguang.  I mean, space for separate family and given name and
> capitalize both.  But I'm not familiar pinyin rule. I don't intend
> to say your naming looks strange.

There is no standardized way for how Asian names (certainly not in the
Japanese and Chinese names which I have observed) are rendered into
English.  Sometimes the family name is given first (which is the order
used in Chinese names); sometimes it is given last (to confirm with
Western expectations).  Sometimes they are capitalized and with
spaces; sometimes not.  Given that the very *concept* of
capitalization doesn't exist at all in Chinese, this should not be
surprising.

Names are very personal things, and in my opinion it's better if we
not try to impose expectations of how names should be rendered of
expect people who wish to interact with the Linux kernel community.

Regards,

						- Ted

P.S.  My family name is rendered Ts'o because that's how my great
grandfather decided to render it in Hong Kong; there is some dispute
whether he used the Wade-Giles or International Phonetic Alphabet
system.  But in Mandarin using Pinyin it would be rendered as Cao,
which by coincidence is the same last name as another ext4 developer
(Mingming Cao).  And in Yale system in Cantonese, it would be rendered
chou.

The convention used by my family is to capitalize each word separately
and to use the 2nd and 3rd characters of my Chinese name as a middle
name.  i.e., "Yue Tak", as opposed to "Yuetak".  (Further, "Yue" is a
generational marker; all of my paternal cousins have chinese names
that begin "Ts'o Yue", while my father and his brothers have chinese
names that begin "Ts'o On".  This tradition is *not* universal, BTW.)

So between assumptions made that Western computer systems that most
people only have one middle name, and that apostrophe's never show up
in last names, it's always been amusing to see how badly "Theodore Yue
Tak Ts'o" gets mangled even in official documents.  :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
