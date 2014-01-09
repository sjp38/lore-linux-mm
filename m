Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f53.google.com (mail-bk0-f53.google.com [209.85.214.53])
	by kanga.kvack.org (Postfix) with ESMTP id BB06A6B0036
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 04:19:01 -0500 (EST)
Received: by mail-bk0-f53.google.com with SMTP id na10so1042281bkb.12
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 01:19:01 -0800 (PST)
Received: from mail-bk0-x22b.google.com (mail-bk0-x22b.google.com [2a00:1450:4008:c01::22b])
        by mx.google.com with ESMTPS id og3si1661608bkb.279.2014.01.09.01.19.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 09 Jan 2014 01:19:00 -0800 (PST)
Received: by mail-bk0-f43.google.com with SMTP id mz12so1025394bkb.2
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 01:19:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <523.1389252725@jrobl>
References: <CAK25hWOu-Q0H8_RCejDduuLCA1-135BEp_Cn_njurBA4r7zp5g@mail.gmail.com>
	<20140107122301.GC16640@quack.suse.cz>
	<CAK25hWMdfSmZLZQugJ3YU=b6nb7ZQzQFw514e=HV91s0Z-W0nQ@mail.gmail.com>
	<6469.1389157809@jrobl>
	<CAK25hWOUhV2Ygs-Q3cVN-mio+BHB60zJ7J_wZZKb=hOR9mb0ug@mail.gmail.com>
	<523.1389252725@jrobl>
Date: Thu, 9 Jan 2014 14:49:00 +0530
Message-ID: <CAK25hWNTmn=NL9exT1kG9D4ya=hzXWSZUiOj8iYjEfrf_yNTEQ@mail.gmail.com>
Subject: Re: [LSF/MM ATTEND] Stackable Union Filesystem Implementation
From: Saket Sinha <saket.sinha89@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "J. R. Okajima" <hooanon05g@gmail.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

On Thu, Jan 9, 2014 at 1:02 PM, J. R. Okajima <hooanon05g@gmail.com> wrote:
>
> Saket Sinha:
>> > For such purpose, a "block device level union" (instead of filesystem
>> > level union) may be an option for you, such as "dm snapshot".
>> >
>> I imagine that this would make things more complicated as ideally this
>> should be done in a filesystem driver. Again a "block device level
>> union" would all the more have lesser chances of getting this
>> filesystem driver included in the mainline kernel as kernel
>> maintainers prefer the drivers to be as simple as possible.
>
> ??
> I am afraid that I cannot fully understand what you wrote.

I am sorry for not explaining it properly. I was abrupt and hence was
misunderstood. My fault!.

> If you think "dm snapshot" does not exist currently, and you or someone
> else are going to develop a new feature, that is wrong. You already have
> "dm snapshot" feature and you can "stack" the block devices by using it.
> (cf. http://aufs.sourceforge.net/aufs2/report/sq/sq.pdf which is a bit
> old)
NO. I know it very much exists.  It forms the foundation of LVM2,
software RAIDs, dm-crypt disk encryption, and offers additional
features such as file system snapshots and I do not doubt either its
functionality or usage.

What I am referring here is the topic  <storing metadata in multiple
places vs  "block device level union">. See DM operates on block
device/sector, but a stackable =EF=AC=81lesystem operates on =EF=AC=81lesys=
tem/=EF=AC=81le. My
point is this that which is the better approach according to the
kernel maintainers, so that this concept of Unioning gets universally
accepted and we have a mainline kernel union filesystem.

Regards,
Saket Sinha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
