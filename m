Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F09696B026A
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 17:12:57 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id a74so8641763pfg.20
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 14:12:57 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id s90si8950272pfk.415.2018.01.08.14.12.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 08 Jan 2018 14:12:56 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: ppc elf_map breakage with MAP_FIXED_NOREPLACE
In-Reply-To: <7a44f42e-39d0-1c4b-19e0-7df1b0842c18@linux.vnet.ibm.com>
References: <5a4ec4bc.u5I/HzCSE6TLVn02%akpm@linux-foundation.org> <7e35e16a-d71c-2ec8-03ed-b07c2af562f8@linux.vnet.ibm.com> <20180105084631.GG2801@dhcp22.suse.cz> <e81dce2b-5d47-b7d3-efbf-27bc171ba4ab@linux.vnet.ibm.com> <20180107090229.GB24862@dhcp22.suse.cz> <87mv1phptq.fsf@concordia.ellerman.id.au> <7a44f42e-39d0-1c4b-19e0-7df1b0842c18@linux.vnet.ibm.com>
Date: Tue, 09 Jan 2018 09:12:49 +1100
Message-ID: <87tvvw80f2.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Hocko <mhocko@kernel.org>Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

Anshuman Khandual <khandual@linux.vnet.ibm.com> writes:

> On 01/07/2018 04:56 PM, Michael Ellerman wrote:
>> Michal Hocko <mhocko@kernel.org> writes:
>> 
>>> On Sun 07-01-18 12:19:32, Anshuman Khandual wrote:
>>>> On 01/05/2018 02:16 PM, Michal Hocko wrote:
>>> [...]
>>>>> Could you give us more information about the failure please. Debugging
>>>>> patch from http://lkml.kernel.org/r/20171218091302.GL16951@dhcp22.suse.cz
>>>>> should help to see what is the clashing VMA.
>>>> Seems like its re-requesting the same mapping again.
>>> It always seems to be the same mapping which is a bit strange as we
>>> have multiple binaries here. Are these binaries any special? Does this
>>> happen to all bianries (except for init which has obviously started
>>> successfully)? Could you add an additional debugging (at the do_mmap
>>> layer) to see who is requesting the mapping for the first time?
>>>
>>>> [   23.423642] 9148 (sed): Uhuuh, elf segment at 0000000010030000 requested but the memory is mapped already
>>>> [   23.423706] requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
>>> I also find it a bit unexpected that this is an anonymous mapping
>>> because the elf loader should always map a file backed one.
>> Anshuman what machine is this on, and what distro and toolchain is it running?
>> 
>> I don't see this on any of my machines, so I wonder if this is
>> toolchain/distro specific.
>
> POWER9, RHEL 7.4, gcc (GCC) 4.8.5 20150623, GNU Make 3.82 etc.

So what does readelf -a of /bin/sed look like?

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
