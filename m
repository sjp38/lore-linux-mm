Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id DFC256B005A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 14:57:16 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so2509097oag.14
        for <linux-mm@kvack.org>; Fri, 05 Oct 2012 11:57:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <506C0F53.5030500@jp.fujitsu.com>
References: <506C0AE8.40702@jp.fujitsu.com> <506C0F53.5030500@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 5 Oct 2012 14:56:55 -0400
Message-ID: <CAHGf_=o6K71u4+OVsLvfCSRmOTk12TpsgKwsJO6bGdd_6dYnyA@mail.gmail.com>
Subject: Re: [PATCH 4/4] acpi,memory-hotplug : store the node id in acpi_memory_device
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, wency@cn.fujitsu.com

On Wed, Oct 3, 2012 at 6:11 AM, Yasuaki Ishimatsu
<isimatu.yasuaki@jp.fujitsu.com> wrote:
> From: Wen Congyang <wency@cn.fujitsu.com>
>
> The memory device has only one node id. Store the node id when
> enable the memory device, and we can reuse it when removing the
> memory device.

You don't explain why we need this. Then nobody can review nor ack.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
