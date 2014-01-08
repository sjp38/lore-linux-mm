Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f54.google.com (mail-bk0-f54.google.com [209.85.214.54])
	by kanga.kvack.org (Postfix) with ESMTP id B99FD6B0031
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 13:26:58 -0500 (EST)
Received: by mail-bk0-f54.google.com with SMTP id v16so792869bkz.41
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 10:26:58 -0800 (PST)
Received: from mail-bk0-x232.google.com (mail-bk0-x232.google.com [2a00:1450:4008:c01::232])
        by mx.google.com with ESMTPS id o5si590871bkr.56.2014.01.08.10.26.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 10:26:57 -0800 (PST)
Received: by mail-bk0-f50.google.com with SMTP id e11so786079bkh.23
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 10:26:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140108111640.GD8256@quack.suse.cz>
References: <CAK25hWOu-Q0H8_RCejDduuLCA1-135BEp_Cn_njurBA4r7zp5g@mail.gmail.com>
	<20140107122301.GC16640@quack.suse.cz>
	<CAK25hWMdfSmZLZQugJ3YU=b6nb7ZQzQFw514e=HV91s0Z-W0nQ@mail.gmail.com>
	<20140108111640.GD8256@quack.suse.cz>
Date: Wed, 8 Jan 2014 23:56:57 +0530
Message-ID: <CAK25hWN_tWu=HrOzs-eu6UFbp-6G=3pZJs+svcBu0hBxErm02g@mail.gmail.com>
Subject: Re: [LSF/MM ATTEND] Stackable Union Filesystem Implementation
From: Saket Sinha <saket.sinha89@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

>> One of the big problems was that too many copyups were made on the
>> read-write file system. So we decided to implement an union file
>> system designed for diskless systems, with the following
>> functionalities:
>>
>> 1. union between only one read-only and one read-write file systems
>>
>> 2. if only the file metadata are modified, then do not
>> copy the whole file on the read-write files system but
>> only the metadata (stored with a file named as the file
>> itself prefixed by '.me.')
>   So do you do anything special at CERN so that metadata is often modified
> without data being changed? Because there are only two operations where I
> can imagine this to be useful:
> 1) atime update - but you better turn atime off for unioned filesystem
>    anyway.
> 2) xattr update
>
As already mentioned that the issue that we were facing was that "too
many copyups were made on the  read-write file system".
Writes to a file system in a  unioning file system will produce many
duplicated blocks in memory since it uses a stackable filesystem
approach so response time for a particular operation is also a
concern.

Regards,
Saket Sinha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
