Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4CA346B0276
	for <linux-mm@kvack.org>; Sun,  7 Jan 2018 06:27:04 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id e12so4438102pga.5
        for <linux-mm@kvack.org>; Sun, 07 Jan 2018 03:27:04 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id x27si630073pfj.235.2018.01.07.03.27.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Jan 2018 03:27:02 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: ppc elf_map breakage with MAP_FIXED_NOREPLACE (was: Re: mmotm 2018-01-04-16-19 uploaded)
In-Reply-To: <20180107090229.GB24862@dhcp22.suse.cz>
References: <5a4ec4bc.u5I/HzCSE6TLVn02%akpm@linux-foundation.org> <7e35e16a-d71c-2ec8-03ed-b07c2af562f8@linux.vnet.ibm.com> <20180105084631.GG2801@dhcp22.suse.cz> <e81dce2b-5d47-b7d3-efbf-27bc171ba4ab@linux.vnet.ibm.com> <20180107090229.GB24862@dhcp22.suse.cz>
Date: Sun, 07 Jan 2018 22:26:57 +1100
Message-ID: <87mv1phptq.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

Michal Hocko <mhocko@kernel.org> writes:

> On Sun 07-01-18 12:19:32, Anshuman Khandual wrote:
>> On 01/05/2018 02:16 PM, Michal Hocko wrote:
> [...]
>> > Could you give us more information about the failure please. Debugging
>> > patch from http://lkml.kernel.org/r/20171218091302.GL16951@dhcp22.suse.cz
>> > should help to see what is the clashing VMA.
>> 
>> Seems like its re-requesting the same mapping again.
>
> It always seems to be the same mapping which is a bit strange as we
> have multiple binaries here. Are these binaries any special? Does this
> happen to all bianries (except for init which has obviously started
> successfully)? Could you add an additional debugging (at the do_mmap
> layer) to see who is requesting the mapping for the first time?
>
>> [   23.423642] 9148 (sed): Uhuuh, elf segment at 0000000010030000 requested but the memory is mapped already
>> [   23.423706] requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
>
> I also find it a bit unexpected that this is an anonymous mapping
> because the elf loader should always map a file backed one.

Anshuman what machine is this on, and what distro and toolchain is it running?

I don't see this on any of my machines, so I wonder if this is
toolchain/distro specific.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
