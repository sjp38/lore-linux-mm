From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: 2.6.26-rc5-mm2: OOM with 1G free swap
Date: Wed, 11 Jun 2008 16:15:25 +1000
References: <20080609223145.5c9a2878.akpm@linux-foundation.org> <20080611060029.GA5011@martell.zuzino.mipt.ru>
In-Reply-To: <20080611060029.GA5011@martell.zuzino.mipt.ru>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200806111615.25508.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 11 June 2008 16:00, Alexey Dobriyan wrote:
> On Mon, Jun 09, 2008 at 10:31:45PM -0700, Andrew Morton wrote:
> > - This is a bugfixed version of 2.6.26-rc5-mm1 - mainly to repair a
> >   vmscan.c bug which would have prevented testing of the other vmscan.c
> >   bugs^Wchanges.
>
> OOM condition happened with 1G free swap.

Hey, I'm liking this kernel-testers list, btw. Makes it much easier
to help people with problems.

Luckily I suggested it at last KS. Oh wait, I recall everybody
laughed or ignored :) I guess I lack the managerial qualities to
make those kinds of suggestions!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
