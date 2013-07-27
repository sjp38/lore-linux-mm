Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id C809B6B0031
	for <linux-mm@kvack.org>; Sat, 27 Jul 2013 13:45:06 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id d41so2086978eek.19
        for <linux-mm@kvack.org>; Sat, 27 Jul 2013 10:45:05 -0700 (PDT)
Message-ID: <51F40570.9050209@gmail.com>
Date: Sat, 27 Jul 2013 19:37:52 +0200
From: Marco Stornelli <marco.stornelli@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] pram: persistent over-kexec memory file system
References: <1374841763-11958-1-git-send-email-vdavydov@parallels.com> <51F3EA2A.3090905@gmail.com> <51F404D0.6070004@parallels.com>
In-Reply-To: <51F404D0.6070004@parallels.com>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, criu@openvz.org, devel@openvz.org, xemul@parallels.com

Il 27/07/2013 19:35, Vladimir Davydov ha scritto:
> On 07/27/2013 07:41 PM, Marco Stornelli wrote:
>> Il 26/07/2013 14:29, Vladimir Davydov ha scritto:
>>> Hi,
>>>
>>> We want to propose a way to upgrade a kernel on a machine without
>>> restarting all the user-space services. This is to be done with CRIU
>>> project, but we need help from the kernel to preserve some data in
>>> memory while doing kexec.
>>>
>>> The key point of our implementation is leaving process memory in-place
>>> during reboot. This should eliminate most io operations the services
>>> would produce during initialization. To achieve this, we have
>>> implemented a pseudo file system that preserves its content during
>>> kexec. We propose saving CRIU dump files to this file system, kexec'ing
>>> and then restoring the processes in the newly booted kernel.
>>>
>>
>> http://pramfs.sourceforge.net/
>
> AFAIU it's a bit different thing: PRAMFS as well as pstore, which has
> already been merged, requires hardware support for over-reboot
> persistency, so called non-volatile RAM, i.e. RAM which is not directly
> accessible and so is not used by the kernel. On the contrary, what we'd
> like to have is preserving usual RAM on kexec. It is possible, because
> RAM is not reset during kexec. This would allow leaving applications
> working set as well as filesystem caches in place, speeding the reboot
> process as a whole and reducing the downtime significantly.
>
> Thanks.

Actually not. You can use normal system RAM reserved at boot with mem 
parameter without any kernel change. Until an hard reset happens, that 
area will be "persistent".

Regards,

Marco

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
