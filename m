Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 149B96B0031
	for <linux-mm@kvack.org>; Sat, 27 Jul 2013 11:48:44 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id q55so2798511wes.30
        for <linux-mm@kvack.org>; Sat, 27 Jul 2013 08:48:43 -0700 (PDT)
Message-ID: <51F3EA2A.3090905@gmail.com>
Date: Sat, 27 Jul 2013 17:41:30 +0200
From: Marco Stornelli <marco.stornelli@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] pram: persistent over-kexec memory file system
References: <1374841763-11958-1-git-send-email-vdavydov@parallels.com>
In-Reply-To: <1374841763-11958-1-git-send-email-vdavydov@parallels.com>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, criu@openvz.org, devel@openvz.org, xemul@parallels.com

Il 26/07/2013 14:29, Vladimir Davydov ha scritto:
> Hi,
>
> We want to propose a way to upgrade a kernel on a machine without
> restarting all the user-space services. This is to be done with CRIU
> project, but we need help from the kernel to preserve some data in
> memory while doing kexec.
>
> The key point of our implementation is leaving process memory in-place
> during reboot. This should eliminate most io operations the services
> would produce during initialization. To achieve this, we have
> implemented a pseudo file system that preserves its content during
> kexec. We propose saving CRIU dump files to this file system, kexec'ing
> and then restoring the processes in the newly booted kernel.
>

http://pramfs.sourceforge.net/

Marco

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
