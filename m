Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 845216B0092
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 10:58:55 -0400 (EDT)
Received: by iajr24 with SMTP id r24so5684244iaj.14
        for <linux-mm@kvack.org>; Mon, 02 Apr 2012 07:58:54 -0700 (PDT)
Date: Mon, 2 Apr 2012 07:58:35 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: RE: swap on eMMC and other flash
In-Reply-To: <26E7A31274623843B0E8CF86148BFE326FB55F8B@NTXAVZMBX04.azit.micron.com>
Message-ID: <alpine.LSU.2.00.1204020754180.1847@eggly.anvils>
References: <201203301744.16762.arnd@arndb.de> <201203301850.22784.arnd@arndb.de> <alpine.LSU.2.00.1203311230490.10965@eggly.anvils> <26E7A31274623843B0E8CF86148BFE326FB55F8B@NTXAVZMBX04.azit.micron.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luca Porzio (lporzio)" <lporzio@micron.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Rik van Riel <riel@redhat.com>, "linaro-kernel@lists.linaro.org" <linaro-kernel@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Alex Lemberg <alex.lemberg@sandisk.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Saugata Das <saugata.das@linaro.org>, Venkatraman S <venkat@linaro.org>, Yejin Moon <yejin.moon@samsung.com>, Hyojin Jeong <syr.jeong@samsung.com>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, "kernel-team@android.com" <kernel-team@android.com>

On Mon, 2 Apr 2012, Luca Porzio (lporzio) wrote:
> 
> Great topics. As per one of Rik original points:
> 
> > 4) skip writeout of zero-filled pages - this can be a big help
> >     for KVM virtual machines running Windows, since Windows zeroes
> >     out free pages;   simply discarding a zero-filled page is not
> >     at all simple in the current VM, where we would have to iterate
> >     over all the ptes to free the swap entry before being able to
> >     free the swap cache page (I am not sure how that locking would
> >     even work)
> > 
> >     with the extra layer of indirection, the locking for this scheme
> >     can be trivial - either the faulting process gets the old page,
> >     or it gets a new one, either way it'll be zero filled
> > 
> 
> Since it's KVMs realm here, can't KSM simply solve the zero-filled pages problem avoiding unnecessary burden for the Swap subsystem?

I would expect that KSM already does largely handle this, yes.
But it's also quite possible that I'm missing Rik's point.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
