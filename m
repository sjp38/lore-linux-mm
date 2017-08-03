Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id A44746B06D0
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 17:25:25 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 6so11684075qts.7
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 14:25:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t37si11720231qte.148.2017.08.03.14.25.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 14:25:24 -0700 (PDT)
Date: Thu, 3 Aug 2017 23:25:22 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] userfaultfd_zeropage: return -ENOSPC in case mm has gone
Message-ID: <20170803212522.GK21775@redhat.com>
References: <1501136819-21857-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20170731122204.GB4878@dhcp22.suse.cz>
 <20170731133247.GK29716@redhat.com>
 <20170731134507.GC4829@dhcp22.suse.cz>
 <20170802123440.GD17905@rapoport-lnx>
 <20170802155522.GB21775@redhat.com>
 <20170802162248.GA3476@dhcp22.suse.cz>
 <20170802164001.GF21775@redhat.com>
 <20170803172442.GA1026@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170803172442.GA1026@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, stable@vger.kernel.org

On Thu, Aug 03, 2017 at 08:24:43PM +0300, Mike Rapoport wrote:
> Now, seriously, I believe there are not many users of non-cooperative uffd
> if at all and it is very unlikely anybody has it in production.
> 
> I'll send a patch with s/ENOSPC/ESRCH in the next few days.

Ok.

Some more thought on this one, enterprise kernels have been shipped
matching the v4.11-v4.12 upstream kernel ABI and I've no time machine
to alter the kABI on those installs.

If you go ahead with the change, the safest would be that you keep
handling -ENOSPC and -ESRCH equally in CRIU code, so there will be no
risk of regression in the short term if somebody is playing with an
upstream CRIU. The alternative would be add uname -r knowledge.

Once it's upstream, I can fixup so further kernel updates will go in
sync. I obviously can't make changes that affects the kABI until it's
upstream and shipped in a official release so things will be out of
sync for a while (and the risk of somebody using ancient kernels will
persist for the mid term).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
