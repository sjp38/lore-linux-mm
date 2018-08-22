Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B45946B24E5
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 11:56:52 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id u22-v6so1938832qkk.10
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 08:56:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 203-v6si1986771qkf.262.2018.08.22.08.56.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 08:56:51 -0700 (PDT)
Date: Wed, 22 Aug 2018 11:56:47 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/2] fix for "pathological THP behavior"
Message-ID: <20180822155647.GQ13047@redhat.com>
References: <20180820032204.9591-1-aarcange@redhat.com>
 <20180820115818.mmeayjkplux2z6im@kshutemo-mobl1>
 <20180820151905.GB13047@redhat.com>
 <6120e1b6-b4d2-96cb-2555-d8fab65c23c8@suse.cz>
 <20180822092440.GH29735@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180822092440.GH29735@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>

On Wed, Aug 22, 2018 at 11:24:40AM +0200, Michal Hocko wrote:
> abuse elsewhere. Like here for the THP. I am pretty sure that the
> intention was not to stick to a specific node but rather all local nodes
> within the reclaim distance (or other unit to define that nodes are
> sufficiently close).

If it meant more than one node but still not all, the same problem
would then happen after the app used all RAM from those "sufficiently
close" nodes. So overall it would make zero difference because it
would just kick the bug down the road a bit more.

Thanks,
Andrea
