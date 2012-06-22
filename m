Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id B8EDF6B01FB
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 10:38:13 -0400 (EDT)
Message-ID: <1340375872.18025.77.camel@twins>
Subject: Re: [PATCH -mm v2 01/11] mm: track free size between VMAs in VMA
 rbtree
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 22 Jun 2012 16:37:52 +0200
In-Reply-To: <4FE48054.5090407@redhat.com>
References: <1340315835-28571-1-git-send-email-riel@surriel.com>
	   <1340315835-28571-2-git-send-email-riel@surriel.com>
	  <1340359115.18025.57.camel@twins> <4FE47D0E.3000804@redhat.com>
	 <1340374439.18025.75.camel@twins> <4FE48054.5090407@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org

On Fri, 2012-06-22 at 10:25 -0400, Rik van Riel wrote:
> On 06/22/2012 10:13 AM, Peter Zijlstra wrote:
> > On Fri, 2012-06-22 at 10:11 -0400, Rik van Riel wrote:
> >>
> >> I am still trying to wrap my brain around your alternative
> >> search algorithm, not sure if/how it can be combined with
> >> arbitrary address limits and alignment...
> >
> > for alignment we can do: len +=3D align - 1;
>=20
> We could, but that might lead us to returning -ENOMEM
> when we actually have memory available.
>=20
> When you consider architectures like HPPA, which use
> a pretty large alignment, but align everything the same,
> chances are pretty much every freed hole will have the
> right alignment...

Well, if you don't your gap heap is next to useless and you'll revert to
simply walking all gaps until you find a suitable one.

I really worry about this search function of yours, its complexity is
very non obvious.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
