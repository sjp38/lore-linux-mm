Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9EB336B0071
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 11:37:42 -0400 (EDT)
Received: by wgme6 with SMTP id e6so106550926wgm.2
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 08:37:42 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l9si1904656wiv.44.2015.06.08.08.37.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 08:37:40 -0700 (PDT)
Date: Mon, 8 Jun 2015 17:37:40 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -resend] jbd2: revert must-not-fail allocation loops back
 to GFP_NOFAIL
Message-ID: <20150608153740.GC1390@dhcp22.suse.cz>
References: <1433770124-19614-1-git-send-email-mhocko@suse.cz>
 <20150608145432.GB19168@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150608145432.GB19168@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org, David Rientjes <rientjes@google.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 08-06-15 10:54:32, Theodore Ts'o wrote:
> On Mon, Jun 08, 2015 at 03:28:44PM +0200, Michal Hocko wrote:
> > This basically reverts 47def82672b3 (jbd2: Remove __GFP_NOFAIL from jbd2
> > layer). The deprecation of __GFP_NOFAIL was a bad choice because it led
> > to open coding the endless loop around the allocator rather than
> > removing the dependency on the non failing allocation. So the
> > deprecation was a clear failure and the reality tells us that
> > __GFP_NOFAIL is not even close to go away.
> > 
> > It is still true that __GFP_NOFAIL allocations are generally discouraged
> > and new uses should be evaluated and an alternative (pre-allocations or
> > reservations) should be considered but it doesn't make any sense to lie
> > the allocator about the requirements. Allocator can take steps to help
> > making a progress if it knows the requirements.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > Acked-by: David Rientjes <rientjes@google.com>
> 
> Applied, thanks.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
