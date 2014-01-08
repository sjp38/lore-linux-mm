Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f44.google.com (mail-bk0-f44.google.com [209.85.214.44])
	by kanga.kvack.org (Postfix) with ESMTP id 104196B0036
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 13:06:19 -0500 (EST)
Received: by mail-bk0-f44.google.com with SMTP id d7so791032bkh.31
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 10:06:19 -0800 (PST)
Received: from mail-bk0-x230.google.com (mail-bk0-x230.google.com [2a00:1450:4008:c01::230])
        by mx.google.com with ESMTPS id kb4si571553bkb.219.2014.01.08.10.06.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 10:06:18 -0800 (PST)
Received: by mail-bk0-f48.google.com with SMTP id r7so788756bkg.35
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 10:06:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <6469.1389157809@jrobl>
References: <CAK25hWOu-Q0H8_RCejDduuLCA1-135BEp_Cn_njurBA4r7zp5g@mail.gmail.com>
	<20140107122301.GC16640@quack.suse.cz>
	<CAK25hWMdfSmZLZQugJ3YU=b6nb7ZQzQFw514e=HV91s0Z-W0nQ@mail.gmail.com>
	<6469.1389157809@jrobl>
Date: Wed, 8 Jan 2014 23:36:18 +0530
Message-ID: <CAK25hWOUhV2Ygs-Q3cVN-mio+BHB60zJ7J_wZZKb=hOR9mb0ug@mail.gmail.com>
Subject: Re: [LSF/MM ATTEND] Stackable Union Filesystem Implementation
From: Saket Sinha <saket.sinha89@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "J. R. Okajima" <hooanon05g@gmail.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

>> Several implementations of union file system fusion were evaluated.
>> The results of the evaluation is shown at the below link-
>> http://www.4shared.com/download/7IgHqn4tce/1_online.png
>
> As far as I know, aufs supports NFS branches and also you can export
> aufs via NFS.
> For example,
> http://sourceforge.net/p/aufs/mailman/message/20639513/
>
>
I am not sure of this. These results were given to me by Cern and I
really have to check this out to make sure it works.


>> 2. if only the file metadata are modified, then do not
>> copy the whole file on the read-write files system but
>> only the metadata (stored with a file named as the file
>> itself prefixed by '.me.')
>
> Once I have considered such approach to implement it in aufs.
> But I don't think it a good idea to store metadata in multiple places,
> one in the original file and the other is in .me. file.
> For such purpose, a "block device level union" (instead of filesystem
> level union) may be an option for you, such as "dm snapshot".
>
I imagine that this would make things more complicated as ideally this
should be done in a filesystem driver. Again a "block device level
union" would all the more have lesser chances of getting this
filesystem driver included in the mainline kernel as kernel
maintainers prefer the drivers to be as simple as possible.

Before taking any approach I really want to discuss it with kernel
maintainers as to what solution they are expecting. The truth is that
the architecture of Linux kernel is such that a stackable filesystem
implementation would surely involve some vicious hacks.

Regards,
Saket Sinha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
