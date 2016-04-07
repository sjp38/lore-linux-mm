Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id E2FE16B025E
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 16:15:31 -0400 (EDT)
Received: by mail-io0-f176.google.com with SMTP id q128so107627586iof.3
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 13:15:31 -0700 (PDT)
Received: from resqmta-po-03v.sys.comcast.net (resqmta-po-03v.sys.comcast.net. [2001:558:fe16:19:96:114:154:162])
        by mx.google.com with ESMTPS id j10si1154037igx.94.2016.04.07.13.15.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Apr 2016 13:15:31 -0700 (PDT)
Date: Thu, 7 Apr 2016 15:15:27 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v5 1/2] mm, vmstat: calculate particular vm event
In-Reply-To: <1460050010-10705-1-git-send-email-ebru.akagunduz@gmail.com>
Message-ID: <alpine.DEB.2.20.1604071512060.16534@east.gentwo.org>
References: <1460049861-10646-1-git-send-email-ebru.akagunduz@gmail.com> <1460050010-10705-1-git-send-email-ebru.akagunduz@gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com

On Thu, 7 Apr 2016, Ebru Akagunduz wrote:

> Currently, vmstat can calculate specific vm event with all_vm_events()
> however it allocates all vm events to stack. This patch introduces
> a helper to sum value of a specific vm event over all cpu, without
> loading all the events.

The first sentence is inaccurate. all_vm_events() takes a pointer to an
array of  of counters and does not allocate on the stack. Fix this and
then add

Acked-by: Christoph Lameter <cl@linux.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
