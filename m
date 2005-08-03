Date: Wed, 3 Aug 2005 12:57:03 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
In-Reply-To: <OFE9263DCA.5243AC8F-ON42257052.0038D22F-42257052.00392CDD@de.ibm.com>
Message-ID: <Pine.LNX.4.61.0508031251140.14149@goblin.wat.veritas.com>
References: <OFE9263DCA.5243AC8F-ON42257052.0038D22F-42257052.00392CDD@de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, Robin Holt <holt@sgi.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Nick Piggin <nickpiggin@yahoo.com.au>, Roland McGrath <roland@redhat.com>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Aug 2005, Martin Schwidefsky wrote:
> Hugh Dickins <hugh@veritas.com> wrote on 08/02/2005 10:55:31 PM:
> >
> > Here we are: get_user_pages quite untested, let alone the racy case,
> 
> Ahh, just tested it and everythings seems to work (even for s390)..
> I'm happy :-)

Thanks for testing, Martin.  Your happiness is my bliss.  Whether
we go with Nick's mods on mine or not, I think you can now safely
assume we've given up demanding a sudden change at the s390 end.

Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
