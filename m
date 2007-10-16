From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch][rfc] rewrite ramdisk
Date: Tue, 16 Oct 2007 18:26:55 +1000
References: <200710151028.34407.borntraeger@de.ibm.com> <200710161807.41157.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0710161015310.10197@fbirervta.pbzchgretzou.qr>
In-Reply-To: <Pine.LNX.4.64.0710161015310.10197@fbirervta.pbzchgretzou.qr>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200710161826.55834.nickpiggin@yahoo.com.au>
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Engelhardt <jengelh@computergmbh.de>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

On Tuesday 16 October 2007 18:17, Jan Engelhardt wrote:
> On Oct 16 2007 18:07, Nick Piggin wrote:
> >Changed. But it will hopefully just completely replace rd.c,
> >so I will probably just rename it to rd.c at some point (and
> >change .config options to stay compatible). Unless someone
> >sees a problem with that?
>
> I do not see a problem with keeping brd either.

Just doesn't seem to be any point in making it a new and different
module, assuming it can support exactly the same semantics. I'm
only doing so in these first diffs so that they are easier to read
and also easier to do a side by side comparison / builds with the
old rd.c


> >> It also does not seem needed, since it did not exist before.
> >> It should go, you can set the variable with brd.rd_nr=XXX (same
> >> goes for ramdisk_size).
> >
> >But only if it's a module?
>
> Attributes always work. Try vt.default_red=0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
> and you will see.

Ah, nice. (I don't use them much!). Still, backward compat I
think is needed if we are to replace rd.c.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
