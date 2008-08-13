Date: Wed, 13 Aug 2008 17:03:14 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC PATCH for -mm 1/5]  mlock() fix return values for mainline
In-Reply-To: <1218573542.6360.136.camel@lts-notebook>
References: <20080811160128.9459.KOSAKI.MOTOHIRO@jp.fujitsu.com> <1218573542.6360.136.camel@lts-notebook>
Message-Id: <20080813170235.E770.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Mon, 2008-08-11 at 16:04 +0900, KOSAKI Motohiro wrote:
> > following patch is the same to http://marc.info/?l=linux-kernel&m=121750892930775&w=2
> > and it already stay in linus-tree.
> > 
> > but it is not merged in 2.6.27-rc1-mm1.
> > 
> > So, please apply it first.
> 
> Kosaki-san:
> 
> make_pages_present() is called from other places than mlock[_fixup()].
> However, I guess it's OK to put mlock() specific behavior in
> make_pages_present() as all other callers [currently] ignore the return
> value.  Is that your thinking?

yup, others ignore it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
