Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 823976B02C3
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 05:50:11 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x28so5783982wma.7
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 02:50:11 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id s71si517282wmd.7.2017.08.11.02.50.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 11 Aug 2017 02:50:10 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id E02E5992AE
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 09:50:09 +0000 (UTC)
Date: Fri, 11 Aug 2017 10:50:09 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [v6 04/15] mm: discard memblock data later
Message-ID: <20170811095009.hz2vnatcwztffraw@techsingularity.net>
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-5-git-send-email-pasha.tatashin@oracle.com>
 <20170811093249.GE30811@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170811093249.GE30811@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, Mel Gorman <mgorman@suse.de>

On Fri, Aug 11, 2017 at 11:32:49AM +0200, Michal Hocko wrote:
> > Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> > Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
> > Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> > Reviewed-by: Bob Picco <bob.picco@oracle.com>
> 
> Considering that some HW might behave strangely and this would be rather
> hard to debug I would be tempted to mark this for stable. It should also
> be merged separately from the rest of the series.
> 
> I have just one nit below
> Acked-by: Michal Hocko <mhocko@suse.com>
> 

Agreed.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
