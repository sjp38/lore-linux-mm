Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1CF866B0037
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 09:17:55 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id y10so3228684pdj.37
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 06:17:54 -0800 (PST)
Received: from mail03-md.ns.itscom.net (mail03-md.ns.itscom.net. [175.177.155.113])
        by mx.google.com with ESMTP id y1si4060084pbm.154.2014.01.09.06.17.52
        for <linux-mm@kvack.org>;
        Thu, 09 Jan 2014 06:17:53 -0800 (PST)
From: "J. R. Okajima" <hooanon05g@gmail.com>
Subject: Re: [LSF/MM ATTEND] Stackable Union Filesystem Implementation
In-Reply-To: <CAK25hWNTmn=NL9exT1kG9D4ya=hzXWSZUiOj8iYjEfrf_yNTEQ@mail.gmail.com>
References: <CAK25hWOu-Q0H8_RCejDduuLCA1-135BEp_Cn_njurBA4r7zp5g@mail.gmail.com> <20140107122301.GC16640@quack.suse.cz> <CAK25hWMdfSmZLZQugJ3YU=b6nb7ZQzQFw514e=HV91s0Z-W0nQ@mail.gmail.com> <6469.1389157809@jrobl> <CAK25hWOUhV2Ygs-Q3cVN-mio+BHB60zJ7J_wZZKb=hOR9mb0ug@mail.gmail.com> <523.1389252725@jrobl> <CAK25hWNTmn=NL9exT1kG9D4ya=hzXWSZUiOj8iYjEfrf_yNTEQ@mail.gmail.com>
Date: Thu, 09 Jan 2014 23:17:51 +0900
Message-ID: <8411.1389277071@jrobl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Saket Sinha <saket.sinha89@gmail.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org


Saket,
Thanks for explanation.

Saket Sinha:
> What I am referring here is the topic  <storing metadata in multiple
> places vs  "block device level union">. See DM operates on block
> device/sector, but a stackable =EF=AC=81lesystem operates on =EF=AC=81lesys=
> tem/=EF=AC=81le. My
> point is this that which is the better approach according to the
> kernel maintainers, so that this concept of Unioning gets universally
> accepted and we have a mainline kernel union filesystem.

While I don't know who prefers which approach, generally speaking, if
you get what you want by an existing technology, it must be better to
use it.
Your ".me." approach will surely reduce the consumed blocks in the upper
layer, but it of course contains a new overhead to maintain the
information stored in ".me.".
Additionally, as a result of ".me." approach, the upper layer will
have info as not an ordinary file. I mean, fileA exists on the lower
layer, but its metadata exists on the upper layer. So if a user
(regardless within union or out of union) wants a complete fileA, then
he has to get info from two places and merge them. Such situation looks
similar to "block device level union".

Currently it is unclear which evolution way hepunion will take, but if
you want
- filesystem-type union (instead of mount-type union nor block device
  level union)
- and name-based union (insated of inode-based union)
then the approach is similar to overlayfs's.
So it might be better to make overlayfs as the base of your development.
If supporting NFS branch (or exporting hepunion) is important for you,
then the inode-based solution will be necessary.


J. R. Okajima

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
