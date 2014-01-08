Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 00AF46B0035
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 00:10:11 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id p10so1294192pdj.26
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 21:10:11 -0800 (PST)
Received: from mail03-md.ns.itscom.net (mail03-md.ns.itscom.net. [175.177.155.113])
        by mx.google.com with ESMTP id fu1si60288287pbc.314.2014.01.07.21.10.10
        for <linux-mm@kvack.org>;
        Tue, 07 Jan 2014 21:10:10 -0800 (PST)
From: "J. R. Okajima" <hooanon05g@gmail.com>
Subject: Re: [LSF/MM ATTEND] Stackable Union Filesystem Implementation
In-Reply-To: <CAK25hWMdfSmZLZQugJ3YU=b6nb7ZQzQFw514e=HV91s0Z-W0nQ@mail.gmail.com>
References: <CAK25hWOu-Q0H8_RCejDduuLCA1-135BEp_Cn_njurBA4r7zp5g@mail.gmail.com> <20140107122301.GC16640@quack.suse.cz> <CAK25hWMdfSmZLZQugJ3YU=b6nb7ZQzQFw514e=HV91s0Z-W0nQ@mail.gmail.com>
Date: Wed, 08 Jan 2014 14:10:09 +0900
Message-ID: <6469.1389157809@jrobl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Saket Sinha <saket.sinha89@gmail.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org


Saket Sinha:
> Several implementations of union file system fusion were evaluated.
> The results of the evaluation is shown at the below link-
> http://www.4shared.com/download/7IgHqn4tce/1_online.png

As far as I know, aufs supports NFS branches and also you can export
aufs via NFS.
For example,
http://sourceforge.net/p/aufs/mailman/message/20639513/


> 2. if only the file metadata are modified, then do not
> copy the whole file on the read-write files system but
> only the metadata (stored with a file named as the file
> itself prefixed by '.me.')

Once I have considered such approach to implement it in aufs.
But I don't think it a good idea to store metadata in multiple places,
one in the original file and the other is in .me. file.
For such purpose, a "block device level union" (instead of filesystem
level union) may be an option for you, such as "dm snapshot".


J. R. Okajima

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
