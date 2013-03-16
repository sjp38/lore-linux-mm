Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 9E6E86B0038
	for <linux-mm@kvack.org>; Sat, 16 Mar 2013 05:25:44 -0400 (EDT)
Received: by mail-oa0-f47.google.com with SMTP id o17so4183426oag.20
        for <linux-mm@kvack.org>; Sat, 16 Mar 2013 02:25:43 -0700 (PDT)
MIME-Version: 1.0
Date: Sat, 16 Mar 2013 17:25:43 +0800
Message-ID: <CAJd=RBDHwgtm=to3WUj73d7q6cjJ7oG6capjUxvcpVk0wH-fbQ@mail.gmail.com>
Subject: Re: OOM triggered with plenty of memory free
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Woithe <jwoithe@atrad.com.au>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> Some system specifications:
> - CPU: i7 860 at 2.8 GHz
> - Mainboard: Advantech AIMB-780
> - RAM: 4 GB
> - Kernel: 2.6.35.11 SMP, 32 bit (kernel.org kernel, no patches applied)
>
The highmem no longer holds memory with 64-bit kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
