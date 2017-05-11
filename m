Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5852F6B02EE
	for <linux-mm@kvack.org>; Thu, 11 May 2017 11:33:55 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id r63so22730479itc.2
        for <linux-mm@kvack.org>; Thu, 11 May 2017 08:33:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u184si839835ith.115.2017.05.11.08.33.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 May 2017 08:33:54 -0700 (PDT)
Date: Thu, 11 May 2017 12:33:29 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [patch 3/3] MM: allow per-cpu vmstat_worker configuration
Message-ID: <20170511153326.GB2308@amt.cnet>
References: <20170503184007.174707977@redhat.com>
 <20170503184039.901336380@redhat.com>
 <1494430466.29205.17.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1494430466.29205.17.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Luiz Capitulino <lcapitulino@redhat.com>, Linux RT Users <linux-rt-users@vger.kernel.org>

On Wed, May 10, 2017 at 11:34:26AM -0400, Rik van Riel wrote:
> On Wed, 2017-05-03 at 15:40 -0300, Marcelo Tosatti wrote:
> > Following the reasoning on the last patch in the series,
> > this patch allows configuration of the per-CPU vmstat worker:
> > it allows the user to disable the per-CPU vmstat worker.
> > 
> > Signed-off-by: Marcelo Tosatti <mtosatti@redhat.com>
> 
> Is there ever a case where you would want to configure
> this separately from the vmstat_threshold parameter?
> 
> What use cases are you trying to address?

If you have a case where the performance decrease due to lack of vmstat
collection aggretation (vmstat_threshold=1) is significant, so you
increase vmstat_threshold on these CPUs to, say, 10 (and is willing to
accept the cost of outdated vmstatistics by 10).

This is the case that i imagined when separating the options in two
(with the idea to have policy in userspace, not in the kernel).

Do you think such case is not realistic? (Or that there are other
problems by having vmstat_threshold > 1 and vmstat_worker=0).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
