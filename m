Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 122E46B005A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 14:54:23 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id va7so2435167obc.14
        for <linux-mm@kvack.org>; Fri, 05 Oct 2012 11:54:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <506C0EC6.9000503@jp.fujitsu.com>
References: <506C0AE8.40702@jp.fujitsu.com> <506C0EC6.9000503@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 5 Oct 2012 14:54:01 -0400
Message-ID: <CAHGf_=rCoCs2Lu9gjydTECRydvOkXfbzFGNKJ52CW9oTiOT2Og@mail.gmail.com>
Subject: Re: [PATCH 3/6] acpi,memory-hotplug : add physical memory hotplug
 code to acpi_memhotplug.c
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, wency@cn.fujitsu.com

On Wed, Oct 3, 2012 at 6:09 AM, Yasuaki Ishimatsu
<isimatu.yasuaki@jp.fujitsu.com> wrote:
> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>
> For hot removing physical memory, the patch adds remove_memory() into
> acpi_memory_remove_memory(). But we cannot support physical memory
> hot remove. So remove_memory() do nothinig.

I don't understand this explanation. Why do we need do nothing change?
I guess you need to fold this patch into another meaningful fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
