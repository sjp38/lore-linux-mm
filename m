Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 708776B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 20:02:16 -0400 (EDT)
Received: by pdbqm3 with SMTP id qm3so29699424pdb.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 17:02:16 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id y3si11466860pdd.227.2015.07.09.17.02.14
        for <linux-mm@kvack.org>;
        Thu, 09 Jul 2015 17:02:15 -0700 (PDT)
Message-ID: <559F0B84.6020908@lge.com>
Date: Fri, 10 Jul 2015 09:02:12 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [RFCv3 0/5] enable migration of driver pages
References: <1436243785-24105-1-git-send-email-gioh.kim@lge.com> <20150707153701.bfcde75108d1fb8aaedc8134@linux-foundation.org> <559C68B3.3010105@lge.com> <20150707170746.1b91ba0d07382cbc9ba3db92@linux-foundation.org> <559C6CA6.1050809@lge.com> <CAPM=9txmUJ58=CAxDhf12Y3Y8wz7CGBy-Bd4pQ8YAAKDsCxU8w@mail.gmail.com> <559DB86D.40000@lge.com> <20150709130848.GD21858@phenom.ffwll.local>
In-Reply-To: <20150709130848.GD21858@phenom.ffwll.local>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Airlie <airlied@gmail.com>, dri-devel <dri-devel@lists.freedesktop.org>, Andrew Morton <akpm@linux-foundation.org>, jlayton@poochiereds.net, bfields@fieldses.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, Al Viro <viro@zeniv.linux.org.uk>, "Michael S. Tsirkin" <mst@redhat.com>, koct9i@gmail.com, minchan@kernel.org, aquini@redhat.com, linux-fsdevel@vger.kernel.org, "open list:VIRTIO CORE, NET..." <virtualization@lists.linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, open@kvack.org, "list@kvack.org: ABI/API" <linux-api@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, gunho.lee@lge.com, Gioh Kim <gurugio@hanmail.net>



2015-07-09 i??i?? 10:08i?? Daniel Vetter i?'(e??) i?' e,?:
> Also there's a bit a lack of gpu drivers from the arm world in upstream,
> which is probabyl why this patch series doesn't come with a user. Might be
> better to first upstream the driver before talking about additional
> infrastructure that it needs.
> -Daniel

I'm not from ARM but I just got the idea of driver page migration
during I worked with ARM gpu driver.
I'm sure this patch is good for zram and balloon
and hope it can be applied to drivers consuming many pages and generating fragmentation,
such as GPU or gfx driver.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
