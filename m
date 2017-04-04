Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7C41D6B0038
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 15:04:24 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id p68so34255902qkf.20
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 12:04:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r51si15826482qta.118.2017.04.04.12.04.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 12:04:23 -0700 (PDT)
Date: Tue, 4 Apr 2017 21:04:19 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v3] userfaultfd: provide pid in userfault msg
Message-ID: <20170404190419.GA5081@redhat.com>
References: <1491211956-6095-1-git-send-email-a.perevalov@samsung.com>
 <CGME20170403093318eucas1p2ebd57e5e4c33707063687ccd571f67bb@eucas1p2.samsung.com>
 <1491211956-6095-2-git-send-email-a.perevalov@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1491211956-6095-2-git-send-email-a.perevalov@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Perevalov <a.perevalov@samsung.com>
Cc: linux-mm@kvack.org, rppt@linux.vnet.ibm.com, mike.kravetz@oracle.com, dgilbert@redhat.com

Hello Alexey,

v3 looks great to me.

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

On top of v3 I think we could add this to make it more obvious to the
developer tpid isn't necessarily there by just looking at the data
structure.

This is purely cosmetical, so feel free to comment if you
disagree.

I'm also fine to add an anonymous union later if a new usage for those
bytes emerges (ABI side doesn't change anything which is why this
could be done later as well, only the API changes here but then I
doubt we'd break the API later for this, so if we want pagefault.feat.*
it probably should be done right now).

Thanks,
Andrea
