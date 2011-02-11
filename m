Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4EF228D0039
	for <linux-mm@kvack.org>; Fri, 11 Feb 2011 17:10:18 -0500 (EST)
MIME-Version: 1.0
Message-ID: <b4feb995-1e73-4c12-8c58-ad0c2252233c@default>
Date: Fri, 11 Feb 2011 14:09:03 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: mmotm 2011-02-10-16-26 uploaded
References: <201102110100.p1B10sDx029244@imap1.linux-foundation.org
 53491.1297461155@localhost>
In-Reply-To: <53491.1297461155@localhost>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu, akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Nitin Gupta <ngupta@vflare.org>

> From: Valdis.Kletnieks@vt.edu [mailto:Valdis.Kletnieks@vt.edu]
> Sent: Friday, February 11, 2011 2:53 PM
> To: akpm@linux-foundation.org; Dan Magenheimer
> Cc: mm-commits@vger.kernel.org; linux-kernel@vger.kernel.org; linux-
> mm@kvack.org; linux-fsdevel@vger.kernel.org
> Subject: Re: mmotm 2011-02-10-16-26 uploaded
>=20
> On Thu, 10 Feb 2011 16:26:36 PST, akpm@linux-foundation.org said:
> > The mm-of-the-moment snapshot 2011-02-10-16-26 has been uploaded to
> >
> >    http://userweb.kernel.org/~akpm/mmotm/
>=20
> CONFIG_ZCACHE=3Dm dies a horrid death:

Thanks Valdis.  A fix for this has already been posted by
Nitin Gupta and Randy Dunlap here:

https://lkml.org/lkml/2011/2/10/383=20

Another patch for a zcache memory leak has been posted here:

https://lkml.org/lkml/2011/2/10/306=20

I'm sorry that multiple people have run into this in
multiple trees.
I have to admit I am a bit baffled as to what the proper
tree flow is for bug fixes like this, but would be happy
to "follow the process" if I am told what it is or if
someone can point me to a document describing it.

(Clearly making sure there are no bugs at all in a
submission is the best way to go, but I'm afraid
I can't claim to be perfect :-)

Thanks,
Dan

P.S. I suppose there isn't really a good reason for
CONFIG_ZCACHE to be tri-state as it really makes
no sense as a module because, if CONFIG_CLEANCACHE
is enabled, it will always get loaded.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
