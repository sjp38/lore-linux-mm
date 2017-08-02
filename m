Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 898C16B05E4
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 12:40:08 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id c2so24258426qkb.10
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 09:40:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l12si29156004qtl.544.2017.08.02.09.40.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 09:40:07 -0700 (PDT)
Date: Wed, 2 Aug 2017 18:40:01 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] userfaultfd_zeropage: return -ENOSPC in case mm has gone
Message-ID: <20170802164001.GF21775@redhat.com>
References: <1501136819-21857-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20170731122204.GB4878@dhcp22.suse.cz>
 <20170731133247.GK29716@redhat.com>
 <20170731134507.GC4829@dhcp22.suse.cz>
 <20170802123440.GD17905@rapoport-lnx>
 <20170802155522.GB21775@redhat.com>
 <20170802162248.GA3476@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170802162248.GA3476@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, stable@vger.kernel.org

On Wed, Aug 02, 2017 at 06:22:49PM +0200, Michal Hocko wrote:
> ESRCH refers to "no such process". Strictly speaking userfaultfd code is
> about a mm which is gone but that is a mere detail. In fact the owner of

Well this whole issue about which retval, is about a mere detail in
the first place, so I don't think you can discount all other mere
details as irrelevant in the evaluation of a change to solve a mere
detail.

> But as I've said, this might be really risky to change. My impression
> was that userfaultfd is not widely used yet and those can be fixed
> easily but if that is not the case then we have to live with the current
> ENOSPC.

The only change would be for userfaultfd non cooperative mode, and
CRIU is the main user of that. So I think it is up to Mike to decide,
I'm fine either ways. I certainly agree ESRCH could be a slightly
better fit, I only wanted to clarify it's not a 100% match either.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
