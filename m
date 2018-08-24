Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id AC9066B2E81
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 03:44:43 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id j129-v6so628137wmj.3
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 00:44:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p15-v6sor1248828wrj.71.2018.08.24.00.44.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 Aug 2018 00:44:42 -0700 (PDT)
Subject: Re: [PATCH v1] mm: relax deferred struct page requirements
From: Jiri Slaby <jslaby@suse.cz>
References: <20171117014601.31606-1-pasha.tatashin@oracle.com>
 <20171121072416.v77vu4osm2s4o5sq@dhcp22.suse.cz>
 <b16029f0-ada0-df25-071b-cd5dba0ab756@suse.cz>
 <CAGM2rea=_VJJ26tohWQWgfwcFVkp0gb6j1edH1kVLjtxfugf5Q@mail.gmail.com>
 <CAGM2reYcwyOcKrO=WhB3Cf0FNL3ZearC=KvxmTNUU6rkWviQOg@mail.gmail.com>
 <83d035f1-40b4-bed8-6113-f4c5a0c4d22f@suse.cz>
Message-ID: <c4d46b63-5237-d002-faf5-4e0749d825d7@suse.cz>
Date: Fri, 24 Aug 2018 09:44:40 +0200
MIME-Version: 1.0
In-Reply-To: <83d035f1-40b4-bed8-6113-f4c5a0c4d22f@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pavel.tatashin@microsoft.com
Cc: mhocko@kernel.org, Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, benh@kernel.crashing.org, paulus@samba.org, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Reza Arbab <arbab@linux.vnet.ibm.com>, schwidefsky@de.ibm.com, Heiko Carstens <heiko.carstens@de.ibm.com>, x86@kernel.org, LKML <linux-kernel@vger.kernel.org>, tglx@linutronix.de, linuxppc-dev@lists.ozlabs.org, Linux Memory Management List <linux-mm@kvack.org>, linux-s390@vger.kernel.org, mgorman@techsingularity.net

pasha.tatashin@oracle.com -> pavel.tatashin@microsoft.com

due to
 550 5.1.1 Unknown recipient address.


On 08/24/2018, 09:32 AM, Jiri Slaby wrote:
> On 06/19/2018, 09:56 PM, Pavel Tatashin wrote:
>> On Tue, Jun 19, 2018 at 9:50 AM Pavel Tatashin
>> <pasha.tatashin@oracle.com> wrote:
>>>
>>> On Sat, Jun 16, 2018 at 4:04 AM Jiri Slaby <jslaby@suse.cz> wrote:
>>>>
>>>> On 11/21/2017, 08:24 AM, Michal Hocko wrote:
>>>>> On Thu 16-11-17 20:46:01, Pavel Tatashin wrote:
>>>>>> There is no need to have ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT,
>>>>>> as all the page initialization code is in common code.
>>>>>>
>>>>>> Also, there is no need to depend on MEMORY_HOTPLUG, as initialization code
>>>>>> does not really use hotplug memory functionality. So, we can remove this
>>>>>> requirement as well.
>>>>>>
>>>>>> This patch allows to use deferred struct page initialization on all
>>>>>> platforms with memblock allocator.
>>>>>>
>>>>>> Tested on x86, arm64, and sparc. Also, verified that code compiles on
>>>>>> PPC with CONFIG_MEMORY_HOTPLUG disabled.
>>>>>
>>>>> There is slight risk that we will encounter corner cases on some
>>>>> architectures with weird memory layout/topology
>>>>
>>>> Which x86_32-pae seems to be. Many bad page state errors are emitted
>>>> during boot when this patch is applied:
>>>
>>> Hi Jiri,
>>>
>>> Thank you for reporting this bug.
>>>
>>> Because 32-bit systems are limited in the maximum amount of physical
>>> memory, they don't need deferred struct pages. So, we can add depends
>>> on 64BIT to DEFERRED_STRUCT_PAGE_INIT in mm/Kconfig.
>>>
>>> However, before we do this, I want to try reproducing this problem and
>>> root cause it, as it might expose a general problem that is not 32-bit
>>> specific.
>>
>> Hi Jiri,
>>
>> Could you please attach your config and full qemu arguments that you
>> used to reproduce this bug.
> 
> Hi,
> 
> I seem I never replied. Attaching .config and the qemu cmdline:
> $ qemu-kvm -m 2000 -hda /dev/null -kernel bzImage
> 
> "-m 2000" is important to reproduce.
> 
> If I disable CONFIG_DEFERRED_STRUCT_PAGE_INIT (which the patch allowed
> to enable), the error goes away, of course.
> 
> thanks,
> 


-- 
js
suse labs
