Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7080E6B0033
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 10:03:13 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id v69so6098511wmd.2
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 07:03:13 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y11si6505191wry.12.2018.01.09.07.03.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jan 2018 07:03:12 -0800 (PST)
Date: Tue, 9 Jan 2018 16:03:12 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] The usbmon triggers a BUG in ./include/linux/mm.h
Message-ID: <20180109150312.GA24254@kroah.com>
References: <20171228160346.6406d52df0d9afe8cf7a0862@linux-foundation.org>
 <20171229132420.jn2pwabl6pyjo6mk@node.shutemov.name>
 <20180103010238.1e510ac2@lembas.zaitcev.lan>
 <20180103092604.5y4bvh3i644ts3zm@node.shutemov.name>
 <20180108154641.106218e8@lembas.zaitcev.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180108154641.106218e8@lembas.zaitcev.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pete Zaitcev <zaitcev@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-usb@vger.kernel.org

On Mon, Jan 08, 2018 at 03:46:41PM -0600, Pete Zaitcev wrote:
> Automated tests triggered this by opening usbmon and accessing the
> mmap while simultaneously resizing the buffers. This bug was with
> us since 2006, because typically applications only size the buffers
> once and thus avoid racing. Reported by Kirill A. Shutemov.
> 
> Signed-off-by: Pete Zaitcev <zaitcev@redhat.com>
> ---
>  drivers/usb/mon/mon_bin.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)

You forgot a reported-by line :(

I'll go add it, it's been a while since you submitted a kernel patch,
you must have forgotten :)

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
