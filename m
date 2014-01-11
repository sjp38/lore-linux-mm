Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f50.google.com (mail-bk0-f50.google.com [209.85.214.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5EA1E6B0031
	for <linux-mm@kvack.org>; Sat, 11 Jan 2014 12:21:54 -0500 (EST)
Received: by mail-bk0-f50.google.com with SMTP id e11so1961831bkh.9
        for <linux-mm@kvack.org>; Sat, 11 Jan 2014 09:21:53 -0800 (PST)
Received: from mail-bk0-x229.google.com (mail-bk0-x229.google.com [2a00:1450:4008:c01::229])
        by mx.google.com with ESMTPS id ko10si6359506bkb.76.2014.01.11.09.21.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 11 Jan 2014 09:21:53 -0800 (PST)
Received: by mail-bk0-f41.google.com with SMTP id v15so1978257bkz.28
        for <linux-mm@kvack.org>; Sat, 11 Jan 2014 09:21:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <8411.1389277071@jrobl>
References: <CAK25hWOu-Q0H8_RCejDduuLCA1-135BEp_Cn_njurBA4r7zp5g@mail.gmail.com>
	<20140107122301.GC16640@quack.suse.cz>
	<CAK25hWMdfSmZLZQugJ3YU=b6nb7ZQzQFw514e=HV91s0Z-W0nQ@mail.gmail.com>
	<6469.1389157809@jrobl>
	<CAK25hWOUhV2Ygs-Q3cVN-mio+BHB60zJ7J_wZZKb=hOR9mb0ug@mail.gmail.com>
	<523.1389252725@jrobl>
	<CAK25hWNTmn=NL9exT1kG9D4ya=hzXWSZUiOj8iYjEfrf_yNTEQ@mail.gmail.com>
	<8411.1389277071@jrobl>
Date: Sat, 11 Jan 2014 22:51:52 +0530
Message-ID: <CAK25hWPpgShw_mWcqWrwGifMXdvF4qDyNojsBAA-si6KPNX68A@mail.gmail.com>
Subject: Re: [LSF/MM ATTEND] Stackable Union Filesystem Implementation
From: Saket Sinha <saket.sinha89@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "J. R. Okajima" <hooanon05g@gmail.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

> Currently it is unclear which evolution way hepunion will take, but if
> you want
> - filesystem-type union (instead of mount-type union nor block device
>   level union)
> - and name-based union (insated of inode-based union)
> then the approach is similar to overlayfs's.
> So it might be better to make overlayfs as the base of your development.
> If supporting NFS branch (or exporting hepunion) is important for you,
> then the inode-based solution will be necessary.
>
Thanks for the suggestion. I am looking forward to suggestions like
these from the community so that we can have a universal union
filesystem for mainline linux kernel with most of the use
cases(including Cern's).


Regards,
Saket Sinha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
