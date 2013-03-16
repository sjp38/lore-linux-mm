Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id E17F86B0037
	for <linux-mm@kvack.org>; Sat, 16 Mar 2013 05:34:04 -0400 (EDT)
Received: by mail-ve0-f169.google.com with SMTP id 15so3202656vea.14
        for <linux-mm@kvack.org>; Sat, 16 Mar 2013 02:34:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJd=RBDHwgtm=to3WUj73d7q6cjJ7oG6capjUxvcpVk0wH-fbQ@mail.gmail.com>
References: <CAJd=RBDHwgtm=to3WUj73d7q6cjJ7oG6capjUxvcpVk0wH-fbQ@mail.gmail.com>
From: Raymond Jennings <shentino@gmail.com>
Date: Sat, 16 Mar 2013 02:33:23 -0700
Message-ID: <CAGDaZ_ryxdMBm44kotjKyCeFEFk3OURjHav3zVOcQNGwP_ZwAQ@mail.gmail.com>
Subject: Re: OOM triggered with plenty of memory free
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Jonathan Woithe <jwoithe@atrad.com.au>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, Mar 16, 2013 at 2:25 AM, Hillf Danton <dhillf@gmail.com> wrote:
>> Some system specifications:
>> - CPU: i7 860 at 2.8 GHz
>> - Mainboard: Advantech AIMB-780
>> - RAM: 4 GB
>> - Kernel: 2.6.35.11 SMP, 32 bit (kernel.org kernel, no patches applied)

> The highmem no longer holds memory with 64-bit kernel.

I don't really think that's a valid reason to dismiss problems with
32-bit though, as I still use it myself.

Anyway, to the parent poster, could you tell us more, such as how much
ram you had left free?

A printout of /proc/meminfo might help here.

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
