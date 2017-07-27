Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 91DD76B02B4
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 07:58:59 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z53so33790505wrz.10
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 04:58:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r129si3052549wma.40.2017.07.27.04.58.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 04:58:58 -0700 (PDT)
Date: Thu, 27 Jul 2017 13:58:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RESEND PATCH 1/2] userfaultfd: Add feature to request for a
 signal delivery
Message-ID: <20170727115854.GA27766@dhcp22.suse.cz>
References: <1500958062-953846-1-git-send-email-prakash.sangappa@oracle.com>
 <1500958062-953846-2-git-send-email-prakash.sangappa@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1500958062-953846-2-git-send-email-prakash.sangappa@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prakash Sangappa <prakash.sangappa@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, aarcange@redhat.com, rppt@linux.vnet.ibm.com, akpm@linux-foundation.org, mike.kravetz@oracle.com

Please do not forget to provide a man page update with clarified
semantic.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
