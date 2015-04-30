Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0651C6B0032
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 13:28:33 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so70121043wgy.2
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 10:28:32 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fb7si3911433wid.20.2015.04.30.10.28.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Apr 2015 10:28:31 -0700 (PDT)
Date: Thu, 30 Apr 2015 18:28:27 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/13] Parallel struct page initialisation v4
Message-ID: <20150430172827.GA2449@suse.de>
References: <1430410227.8193.0@cpanel21.proisp.no>
 <55426292.4030309@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <55426292.4030309@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nzimmer <nzimmer@sgi.com>
Cc: Daniel J Blueman <daniel@numascale.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 'Steffen Persvold' <sp@numascale.com>

On Thu, Apr 30, 2015 at 12:12:50PM -0500, nzimmer wrote:
> 
> Out of curiosity has anyone ran any tests post boot time?
> 

Some functional tests only to exercise the machine and see if anything
blew up. It looked fine to me at least.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
