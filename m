Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id DAA446B004D
	for <linux-mm@kvack.org>; Thu, 29 May 2014 04:48:23 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lj1so32459pab.17
        for <linux-mm@kvack.org>; Thu, 29 May 2014 01:48:23 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id kv4si27523154pab.78.2014.05.29.01.48.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 May 2014 01:48:22 -0700 (PDT)
Received: by mail-pa0-f51.google.com with SMTP id kq14so28183pab.38
        for <linux-mm@kvack.org>; Thu, 29 May 2014 01:48:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53864B65.8080705@intel.com>
References: <CAJm7N84L7fVJ5x_zPbcYhWm1KMtz3dGA=G9EW=XwBbSKMwxPnw@mail.gmail.com>
	<CAJm7N87bRrP6cFhQaEp9kj2rNJhAKvLAFioh5VBx2jjDGn1DWw@mail.gmail.com>
	<53864B65.8080705@intel.com>
Date: Thu, 29 May 2014 16:48:22 +0800
Message-ID: <CAJm7N87BNiuNkqrU+EeeejXXp_aOH+jVh-kyZr890Aedg__Ftg@mail.gmail.com>
Subject: Re: memory hot-add: the kernel can notify udev daemon before creating
 the sys file state?
From: DX Cui <rijcos@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org, Matt Tolentino <matthew.e.tolentino@intel.com>, Dave Hansen <haveblue@us.ibm.com>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Thu, May 29, 2014 at 4:47 AM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 05/23/2014 05:27 AM, DX Cui wrote:
>> It looks the new "register_memory() --> ... -> device_add()" path has the
>> correct order for sysfs creation and notification udev.
>>
>> It would be great if you can confirm my analysis. :-)
>
> Your analysis looks correct to me.  Nathan's patch does, indeed look
> like a quite acceptable fix.  How far back do those sysfs attribute
> groups go, btw?

I'm not familiar with it.
My gut feeling is: this may need non-trivial efforts -- probably several
extra patches need to be backported too.

BTW, this race condition finally can cause kernel panic when old Linux
VMs of kernel versions <3.9.x, like CentOS 6.5, run on Hyper-V, AND
memory hot-add and the balloon driver are used:

https://bugzilla.redhat.com/show_bug.cgi?id=1102551
(there is a workaround patch for ***CentOS6.5*** in the bug entry)

-- DX

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
