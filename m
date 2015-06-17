Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id F2E4B6B007B
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 05:23:48 -0400 (EDT)
Received: by pacgb13 with SMTP id gb13so31564354pac.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 02:23:48 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id ha1si5330561pbd.249.2015.06.17.02.23.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 17 Jun 2015 02:23:48 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NQ300I870RJ7R00@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 17 Jun 2015 10:23:43 +0100 (BST)
Message-id: <55813C9C.1010608@samsung.com>
Date: Wed, 17 Jun 2015 11:23:40 +0200
From: Beata Michalska <b.michalska@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC v3 4/4] shmem: Add support for generic FS events
References: <1434460173-18427-1-git-send-email-b.michalska@samsung.com>
 <1434460173-18427-5-git-send-email-b.michalska@samsung.com>
 <CALq1K=L-DWP5avgXtc0p5=D_M8tXm+Y45DphP7G9QBYo-5sXFA@mail.gmail.com>
In-reply-to: 
 <CALq1K=L-DWP5avgXtc0p5=D_M8tXm+Y45DphP7G9QBYo-5sXFA@mail.gmail.com>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leon Romanovsky <leon@leon.nu>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, linux-api@vger.kernel.org, Greg Kroah <greg@kroah.com>, jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, Hugh Dickins <hughd@google.com>, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, kyungmin.park@samsung.com, kmpark@infradead.org

On 06/17/2015 08:08 AM, Leon Romanovsky wrote:
>>         }
>> -       if (error == -ENOSPC && !once++) {
>> +       if (error == -ENOSPC) {
>> +               if (!once++) {
>>                 info = SHMEM_I(inode);
>>                 spin_lock(&info->lock);
>>                 shmem_recalc_inode(inode);
>>                 spin_unlock(&info->lock);
>>                 goto repeat;
>> +               } else {
>> +                       fs_event_notify(inode->i_sb, FS_WARN_ENOSPC);
>> +               }
>>         }
> 
> Very minor remark, please fix indentation.
> 

I will, thank You.

BR
Beata

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
