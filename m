Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0D56B6B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 09:18:21 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v13so11088892pgq.1
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 06:18:21 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g16si9760352pfk.461.2017.10.03.06.18.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 06:18:20 -0700 (PDT)
Date: Tue, 3 Oct 2017 15:18:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v9 08/12] mm: zero reserved and unavailable struct pages
Message-ID: <20171003131817.omzbam3js67edp3s@dhcp22.suse.cz>
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-9-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170920201714.19817-9-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

On Wed 20-09-17 16:17:10, Pavel Tatashin wrote:
> Some memory is reserved but unavailable: not present in memblock.memory
> (because not backed by physical pages), but present in memblock.reserved.
> Such memory has backing struct pages, but they are not initialized by going
> through __init_single_page().

Could you be more specific where is such a memory reserved?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
