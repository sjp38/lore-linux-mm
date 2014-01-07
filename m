Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 97F226B0069
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 11:53:02 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id g10so590289pdj.3
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 08:53:02 -0800 (PST)
Received: from mail05-md.ns.itscom.net (mail05-md.ns.itscom.net. [175.177.155.115])
        by mx.google.com with ESMTP id sz7si57352351pab.261.2014.01.07.08.53.00
        for <linux-mm@kvack.org>;
        Tue, 07 Jan 2014 08:53:01 -0800 (PST)
From: "J. R. Okajima" <hooanon05g@gmail.com>
Subject: Re: [LSF/MM ATTEND] Stackable Union Filesystem Implementation
In-Reply-To: <CAK25hWOu-Q0H8_RCejDduuLCA1-135BEp_Cn_njurBA4r7zp5g@mail.gmail.com>
References: <CAK25hWOu-Q0H8_RCejDduuLCA1-135BEp_Cn_njurBA4r7zp5g@mail.gmail.com>
Date: Wed, 08 Jan 2014 01:52:59 +0900
Message-ID: <25625.1389113579@jrobl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Saket Sinha <saket.sinha89@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org


Saket Sinha:
>  1. VFS-based stacking solution- I would like to cite the work done by
> Valerie Aurora was closest.
>
>  2. Non-VFS-based stacking solution -  UnionFS, Aufs and the new Overlay FS

Overayfs is essentially a rewrite of UnionMount (implemented in VFS
layer), to be a filesystem. They both have several unresolved issues by
design "name-based union", and I have pointed out on LKML several times.
For example, here is a URL of my last post about it.
http://marc.info/?l=linux-kernel&m=136310958022160&w=2


> The use case that I am looking from the stackable filesystem is  that
> of "diskless node handling" (for CERN where it is required to provide
> a faster diskless
> booting to the Large Hadron Collider Beauty nodes).

Just out of curious, I remember a guy in CERN had posted a message to
aufs-users ML.
http://www.mail-archive.com/aufs-users@lists.sourceforge.net/msg04020.html

Are you co-working with him? Or CERN totally stopped using aufs?


J. R. Okajima

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
