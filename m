Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 295746B0032
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 02:09:05 -0400 (EDT)
Received: by wgbhy7 with SMTP id hy7so27725515wgb.2
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 23:09:04 -0700 (PDT)
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id m2si7111160wib.0.2015.06.16.23.09.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 23:09:02 -0700 (PDT)
Received: by wgbhy7 with SMTP id hy7so27724954wgb.2
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 23:09:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1434460173-18427-5-git-send-email-b.michalska@samsung.com>
References: <1434460173-18427-1-git-send-email-b.michalska@samsung.com> <1434460173-18427-5-git-send-email-b.michalska@samsung.com>
From: Leon Romanovsky <leon@leon.nu>
Date: Wed, 17 Jun 2015 09:08:41 +0300
Message-ID: <CALq1K=L-DWP5avgXtc0p5=D_M8tXm+Y45DphP7G9QBYo-5sXFA@mail.gmail.com>
Subject: Re: [RFC v3 4/4] shmem: Add support for generic FS events
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Beata Michalska <b.michalska@samsung.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, linux-api@vger.kernel.org, Greg Kroah <greg@kroah.com>, jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, Hugh Dickins <hughd@google.com>, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, kyungmin.park@samsung.com, kmpark@infradead.org

>         }
> -       if (error == -ENOSPC && !once++) {
> +       if (error == -ENOSPC) {
> +               if (!once++) {
>                 info = SHMEM_I(inode);
>                 spin_lock(&info->lock);
>                 shmem_recalc_inode(inode);
>                 spin_unlock(&info->lock);
>                 goto repeat;
> +               } else {
> +                       fs_event_notify(inode->i_sb, FS_WARN_ENOSPC);
> +               }
>         }

Very minor remark, please fix indentation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
