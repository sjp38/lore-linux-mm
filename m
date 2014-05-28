Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8FDA46B0035
	for <linux-mm@kvack.org>; Wed, 28 May 2014 16:47:36 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id md12so11852224pbc.29
        for <linux-mm@kvack.org>; Wed, 28 May 2014 13:47:36 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id qu8si25110439pbb.27.2014.05.28.13.47.35
        for <linux-mm@kvack.org>;
        Wed, 28 May 2014 13:47:35 -0700 (PDT)
Message-ID: <53864B65.8080705@intel.com>
Date: Wed, 28 May 2014 13:47:33 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: memory hot-add: the kernel can notify udev daemon before creating
 the sys file state?
References: <CAJm7N84L7fVJ5x_zPbcYhWm1KMtz3dGA=G9EW=XwBbSKMwxPnw@mail.gmail.com> <CAJm7N87bRrP6cFhQaEp9kj2rNJhAKvLAFioh5VBx2jjDGn1DWw@mail.gmail.com>
In-Reply-To: <CAJm7N87bRrP6cFhQaEp9kj2rNJhAKvLAFioh5VBx2jjDGn1DWw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: DX Cui <rijcos@gmail.com>, linux-mm@kvack.org
Cc: Matt Tolentino <matthew.e.tolentino@intel.com>, Dave Hansen <haveblue@us.ibm.com>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On 05/23/2014 05:27 AM, DX Cui wrote:
> It looks the new "register_memory() --> ... -> device_add()" path has the
> correct order for sysfs creation and notification udev.
> 
> It would be great if you can confirm my analysis. :-)

Your analysis looks correct to me.  Nathan's patch does, indeed look
like a quite acceptable fix.  How far back do those sysfs attribute
groups go, btw?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
