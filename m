Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6B6036B0047
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 04:03:14 -0500 (EST)
Received: by qyk36 with SMTP id 36so1673101qyk.19
        for <linux-mm@kvack.org>; Fri, 26 Feb 2010 01:03:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <84144f021002260056g68e25ecer1dd826ecc5d42a56@mail.gmail.com>
References: <1267166172-14059-1-git-send-email-dmonakhov@openvz.org>
	 <84144f021002260056g68e25ecer1dd826ecc5d42a56@mail.gmail.com>
Date: Fri, 26 Feb 2010 18:03:13 +0900
Message-ID: <961aa3351002260103x53f116f1sb4d3bf8f4435b635@mail.gmail.com>
Subject: Re: [PATCH] failslab: add ability to filter slab caches [v3]
From: Akinobu Mita <akinobu.mita@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Dmitry Monakhov <dmonakhov@openvz.org>, linux-mm@kvack.org, cl@linux-foundation.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

2010/2/26 Pekka Enberg <penberg@cs.helsinki.fi>:
> On Fri, Feb 26, 2010 at 8:36 AM, Dmitry Monakhov <dmonakhov@openvz.org> wrote:
>> This patch allow to inject faults only for specific slabs.
>> In order to preserve default behavior cache filter is off by
>> default (all caches are faulty).
>>
>> One may define specific set of slabs like this:
>> # mark skbuff_head_cache as faulty
>> echo 1 > /sys/kernel/slab/skbuff_head_cache/failslab
>> # Turn on cache filter (off by default)
>> echo 1 > /sys/kernel/debug/failslab/cache-filter
>> # Turn on fault injection
>> echo 1 > /sys/kernel/debug/failslab/times
>> echo 1 > /sys/kernel/debug/failslab/probability
>>
>> Acked-by: David Rientjes <rientjes@google.com>
>> Signed-off-by: Dmitry Monakhov <dmonakhov@openvz.org>
>
> Lets CC the failslab author as well for ACKs.

Acked-by: Akinobu Mita <akinobu.mita@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
