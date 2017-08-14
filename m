Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1B8716B02F4
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 07:34:49 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id w63so13796020wrc.5
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 04:34:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v16si772578wrg.456.2017.08.14.04.34.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 14 Aug 2017 04:34:47 -0700 (PDT)
Date: Mon, 14 Aug 2017 13:34:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v6 04/15] mm: discard memblock data later
Message-ID: <20170814113445.GE19063@dhcp22.suse.cz>
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-5-git-send-email-pasha.tatashin@oracle.com>
 <20170811093249.GE30811@dhcp22.suse.cz>
 <42a04441-47ad-2fa0-ca3c-784c717213f7@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42a04441-47ad-2fa0-ca3c-784c717213f7@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, Mel Gorman <mgorman@suse.de>

On Fri 11-08-17 15:00:47, Pasha Tatashin wrote:
> Hi Michal,
> 
> This suggestion won't work, because there are arches without memblock
> support: tile, sh...
> 
> So, I would still need to have:
> 
> #ifdef CONFIG_MEMBLOCK in page_alloc, or define memblock_discard() stubs in
> nobootmem headfile. 

This is the standard way to do this. And it is usually preferred to
proliferate ifdefs in the code.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
