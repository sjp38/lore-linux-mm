Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8AB886B0261
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 20:56:21 -0400 (EDT)
Received: by qkdv3 with SMTP id v3so144522437qkd.3
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 17:56:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k85si30410059qhc.46.2015.07.21.17.56.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 17:56:20 -0700 (PDT)
Date: Wed, 22 Jul 2015 08:56:14 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH 1/3] percpu: clean up of schunk->map[] assignment in
 pcpu_setup_first_chunk
Message-ID: <20150722005614.GD1834@dhcp-17-102.nay.redhat.com>
References: <1437404130-5188-1-git-send-email-bhe@redhat.com>
 <20150721153308.GI15934@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150721153308.GI15934@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/21/15 at 11:33am, Tejun Heo wrote:
> On Mon, Jul 20, 2015 at 10:55:28PM +0800, Baoquan He wrote:
> > The original assignment is a little redundent.
> > 
> > Signed-off-by: Baoquan He <bhe@redhat.com>
> 
> Heh, I'm not sure this is actually better.  Anyways, applied to
> percpu/for-4.3.  In general tho, I don't really think this level of
> micro cleanup patches are worthwhile.  If something around it changes,
> sure, take the chance and clean it up but as standalone patches these
> aren't that readily justifiable.

Understood. They are very tiny cleanups, not inprovement. Just when
trying to fix a kdump corrupted header bug where cpu information is
stored in percpu variable I tried to understand the whole percpu
implementation and found these. Didn't put them together because that
change is kdump only in kernel/kexec.c and that patch is testing by
customers on big server. Understanding percpu code is always in my
TODO list, now it's done. I am fine if patch like patch 3/3 makes code
messy and should not be applied.

Thanks for your reviewing and suggestion.

Thanks
Baoquan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
