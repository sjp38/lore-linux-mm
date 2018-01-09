Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8E56C6B0033
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 11:13:59 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id v69so6196812wmd.2
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 08:13:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d200si9721251wmd.238.2018.01.09.08.13.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Jan 2018 08:13:57 -0800 (PST)
Date: Tue, 9 Jan 2018 17:13:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: ppc elf_map breakage with MAP_FIXED_NOREPLACE
Message-ID: <20180109161355.GL1732@dhcp22.suse.cz>
References: <5a4ec4bc.u5I/HzCSE6TLVn02%akpm@linux-foundation.org>
 <7e35e16a-d71c-2ec8-03ed-b07c2af562f8@linux.vnet.ibm.com>
 <20180105084631.GG2801@dhcp22.suse.cz>
 <e81dce2b-5d47-b7d3-efbf-27bc171ba4ab@linux.vnet.ibm.com>
 <20180107090229.GB24862@dhcp22.suse.cz>
 <87mv1phptq.fsf@concordia.ellerman.id.au>
 <7a44f42e-39d0-1c4b-19e0-7df1b0842c18@linux.vnet.ibm.com>
 <87tvvw80f2.fsf@concordia.ellerman.id.au>
 <96458c0a-e273-3fb9-a33b-f6f2d536f90b@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <96458c0a-e273-3fb9-a33b-f6f2d536f90b@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

On Tue 09-01-18 17:18:38, Anshuman Khandual wrote:
> On 01/09/2018 03:42 AM, Michael Ellerman wrote:
> > Anshuman Khandual <khandual@linux.vnet.ibm.com> writes:
> > 
> >> On 01/07/2018 04:56 PM, Michael Ellerman wrote:
> >>> Michal Hocko <mhocko@kernel.org> writes:
> >>>
> >>>> On Sun 07-01-18 12:19:32, Anshuman Khandual wrote:
> >>>>> On 01/05/2018 02:16 PM, Michal Hocko wrote:
> >>>> [...]
> >>>>>> Could you give us more information about the failure please. Debugging
> >>>>>> patch from http://lkml.kernel.org/r/20171218091302.GL16951@dhcp22.suse.cz
> >>>>>> should help to see what is the clashing VMA.
> >>>>> Seems like its re-requesting the same mapping again.
> >>>> It always seems to be the same mapping which is a bit strange as we
> >>>> have multiple binaries here. Are these binaries any special? Does this
> >>>> happen to all bianries (except for init which has obviously started
> >>>> successfully)? Could you add an additional debugging (at the do_mmap
> >>>> layer) to see who is requesting the mapping for the first time?
> >>>>
> >>>>> [   23.423642] 9148 (sed): Uhuuh, elf segment at 0000000010030000 requested but the memory is mapped already
> >>>>> [   23.423706] requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
> >>>> I also find it a bit unexpected that this is an anonymous mapping
> >>>> because the elf loader should always map a file backed one.
> >>> Anshuman what machine is this on, and what distro and toolchain is it running?
> >>>
> >>> I don't see this on any of my machines, so I wonder if this is
> >>> toolchain/distro specific.
> >>
> >> POWER9, RHEL 7.4, gcc (GCC) 4.8.5 20150623, GNU Make 3.82 etc.
> > 
> > So what does readelf -a of /bin/sed look like?
> 
> Please find here.

Did you manage to catch _who_ is requesting that anonymous mapping? Do
you need a help with the debugging patch?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
