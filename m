Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f170.google.com (mail-ea0-f170.google.com [209.85.215.170])
	by kanga.kvack.org (Postfix) with ESMTP id 236AC6B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 05:23:56 -0500 (EST)
Received: by mail-ea0-f170.google.com with SMTP id k10so3652202eaj.29
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 02:23:55 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y5si1416386eee.249.2014.01.21.02.23.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 02:23:55 -0800 (PST)
Date: Tue, 21 Jan 2014 10:23:51 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC] restore user defined min_free_kbytes when disabling thp
Message-ID: <20140121102351.GD4963@suse.de>
References: <20140121093859.GA7546@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140121093859.GA7546@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>

On Tue, Jan 21, 2014 at 05:38:59PM +0800, Han Pingtian wrote:
> The testcase 'thp04' of LTP will enable THP, do some testing, then
> disable it if it wasn't enabled. But this will leave a different value
> of min_free_kbytes if it has been set by admin. So I think it's better
> to restore the user defined value after disabling THP.
> 

Then have LTP record what min_free_kbytes was at the same time THP was
enabled by the test and restore both settings. It leaves a window where
an admin can set an alternative value during the test but that would also
invalidate the test in same cases and gets filed under "don't do that".

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
