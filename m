Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E1FC58E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 09:39:14 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id t2so998968edb.22
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 06:39:14 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 7-v6si626616ejq.150.2019.01.23.06.39.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 06:39:13 -0800 (PST)
Subject: Re: [PATCH 1/2] x86: respect memory size limiting via mem= parameter
References: <20190122080628.7238-1-jgross@suse.com>
 <20190122080628.7238-2-jgross@suse.com>
 <69D0866F-77A7-4529-A01E-12395106E22D@oracle.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <222a2429-957c-c6cd-3f46-06a627bbbd5e@suse.com>
Date: Wed, 23 Jan 2019 15:39:11 +0100
MIME-Version: 1.0
In-Reply-To: <69D0866F-77A7-4529-A01E-12395106E22D@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: kernel list <linux-kernel@vger.kernel.org>, xen-devel <xen-devel@lists.xenproject.org>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, sstabellini@kernel.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de

On 23/01/2019 15:35, William Kucharski wrote:
> 
> 
>> On Jan 22, 2019, at 1:06 AM, Juergen Gross <jgross@suse.com> wrote:
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index b9a667d36c55..7fc2a87110a3 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -96,10 +96,16 @@ void mem_hotplug_done(void)
>> 	cpus_read_unlock();
>> }
>>
>> +u64 max_mem_size = -1;
> 
> This may be pedantic, but I'd rather see U64_MAX used here.

Fine with me. Will change.


Juergen
