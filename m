Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8D15F6B0037
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 16:55:32 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id a13so3727306igq.15
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 13:55:32 -0700 (PDT)
Received: from mail-ie0-x235.google.com (mail-ie0-x235.google.com [2607:f8b0:4001:c03::235])
        by mx.google.com with ESMTPS id t20si18867245igr.23.2014.06.05.13.55.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Jun 2014 13:55:31 -0700 (PDT)
Received: by mail-ie0-f181.google.com with SMTP id rp18so1363893iec.26
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 13:55:31 -0700 (PDT)
Date: Thu, 5 Jun 2014 13:55:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, pcp: allow restoring percpu_pagelist_fraction
 default
In-Reply-To: <FB428F94-91FA-4E4F-8DA3-060C3C41F261@linuxhacker.ru>
Message-ID: <alpine.DEB.2.02.1406051354420.18119@chino.kir.corp.google.com>
References: <1399166883-514-1-git-send-email-green@linuxhacker.ru> <alpine.DEB.2.02.1406021837490.13072@chino.kir.corp.google.com> <B549468A-10FC-4897-8720-7C9FEC6FD03A@linuxhacker.ru> <alpine.DEB.2.02.1406022056300.20536@chino.kir.corp.google.com>
 <2C763027-307F-4BC0-8C0A-7E3D5957A4DA@linuxhacker.ru> <alpine.DEB.2.02.1406031819580.8682@chino.kir.corp.google.com> <85AFB547-D3A1-4818-AD82-FF90909775D2@linuxhacker.ru> <alpine.DEB.2.02.1406041734150.17045@chino.kir.corp.google.com>
 <FB428F94-91FA-4E4F-8DA3-060C3C41F261@linuxhacker.ru>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Cody P Schafer <cody@linux.vnet.ibm.com>, Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, devel@driverdev.osuosl.org

On Wed, 4 Jun 2014, Oleg Drokin wrote:

> Minor nitpick I guess, but ret cannot be anything but 0 here I think (until somebody changes the way proc_dointvec_minmax for write=true operates)?
> 

We need to return 0 regardless of whether proc_dointvec_minmax() changes 
in the future, the patch is correct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
