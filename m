Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 701DD6B016D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 04:37:56 -0400 (EDT)
Message-ID: <1340699831.21991.34.camel@twins>
Subject: Re: [PATCH -mm v2 01/11] mm: track free size between VMAs in VMA
 rbtree
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 26 Jun 2012 10:37:11 +0200
In-Reply-To: <4FE8DD80.9040108@redhat.com>
References: <1340315835-28571-1-git-send-email-riel@surriel.com>
	     <1340315835-28571-2-git-send-email-riel@surriel.com>
	    <1340359115.18025.57.camel@twins> <4FE47D0E.3000804@redhat.com>
	   <1340374439.18025.75.camel@twins> <4FE48054.5090407@redhat.com>
	  <1340375872.18025.77.camel@twins> <4FE4922D.8070501@surriel.com>
	 <1340652578.21991.18.camel@twins> <4FE8DD80.9040108@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org

On Mon, 2012-06-25 at 17:52 -0400, Rik van Riel wrote:
> > The thing you propose, the double search, once for len, and once for le=
n
> > +align-1 doesn't guarantee you'll find a hole. All holes of len might b=
e
> > mis-aligned but the len+align-1 search might overlook a hole of suitabl=
e
> > size and alignment, you'd have to search the entire range: [len, len
> > +align-1], and that's somewhat silly.
>=20
> This may still be good enough.=20

OK, as long as this is clearly mentioned in a comment near there.

It just annoys me that I cannot come up with anything better :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
