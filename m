Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id AD1DA6B006C
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 13:28:45 -0400 (EDT)
Received: by oagk14 with SMTP id k14so8180538oag.14
        for <linux-mm@kvack.org>; Tue, 02 Oct 2012 10:28:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <506A36A1.6030709@gmail.com>
References: <1346837155-534-1-git-send-email-wency@cn.fujitsu.com>
 <1346837155-534-7-git-send-email-wency@cn.fujitsu.com> <506A36A1.6030709@gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 2 Oct 2012 13:28:24 -0400
Message-ID: <CAHGf_=rX-OHFkBCKzdOi-ydF3VY+Sv_J1osDzZ_MiYEoop145A@mail.gmail.com>
Subject: Re: [RFC v9 PATCH 06/21] memory-hotplug: export the function acpi_bus_remove()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ni zhan Chen <nizhan.chen@gmail.com>
Cc: wency@cn.fujitsu.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com

On Mon, Oct 1, 2012 at 8:34 PM, Ni zhan Chen <nizhan.chen@gmail.com> wrote:
> On 09/05/2012 05:25 PM, wency@cn.fujitsu.com wrote:
>>
>> From: Wen Congyang <wency@cn.fujitsu.com>
>>
>> The function acpi_bus_remove() can remove a acpi device from acpi device.
>
> IIUC, s/acpi device/acpi bus

IIUC, acpi_bus_remove() mean "remove the device from a bus".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
