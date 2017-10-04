Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7C6786B0038
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 04:45:29 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k10so11463170wrk.4
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 01:45:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g184si3107420wmg.205.2017.10.04.01.45.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Oct 2017 01:45:28 -0700 (PDT)
Date: Wed, 4 Oct 2017 10:45:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v9 12/12] mm: stop zeroing memory during allocation in
 vmemmap
Message-ID: <20171004084526.57uzy3t4ualwxdyt@dhcp22.suse.cz>
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-13-pasha.tatashin@oracle.com>
 <20171003131952.aqq377pjug5me6go@dhcp22.suse.cz>
 <c028f65a-b4a6-e56d-3a50-5d7ad9af50cb@oracle.com>
 <e5872937-b166-fd48-d46d-1921c738d4b1@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e5872937-b166-fd48-d46d-1921c738d4b1@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

On Tue 03-10-17 16:26:51, Pasha Tatashin wrote:
> Hi Michal,
> 
> I decided not to merge these two patches, because in addition to sparc
> optimization move, we have this dependancies:

optimizations can and should go on top of the core patch.

> mm: zero reserved and unavailable struct pages
> 
> must be before
> 
> mm: stop zeroing memory during allocation in vmemmap.
> 
> Otherwise, we can end-up with struct pages that are not zeroed properly.

Right and you can deal with it easily. Just introduce the
mm_zero_struct_page earlier along with its user in "stop zeroing ..."

I think that moving the zeroying in one go is more reasonable than
adding it to __init_single_page with misleading numbers and later
dropping the zeroying from the memmap path.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
