Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id B877B9003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 21:55:30 -0400 (EDT)
Received: by qgii95 with SMTP id i95so80573132qgi.2
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 18:55:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d14si3916194qhc.99.2015.07.22.18.55.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 18:55:29 -0700 (PDT)
Date: Thu, 23 Jul 2015 09:55:23 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH 3/3] percpu: add macro PCPU_CHUNK_AREA_IN_USE
Message-ID: <20150723015523.GC1844@dhcp-17-102.nay.redhat.com>
References: <1437404130-5188-1-git-send-email-bhe@redhat.com>
 <1437404130-5188-3-git-send-email-bhe@redhat.com>
 <20150721153019.GH15934@mtj.duckdns.org>
 <20150722002839.GC1834@dhcp-17-102.nay.redhat.com>
 <20150722135352.GK15934@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150722135352.GK15934@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/22/15 at 09:53am, Tejun Heo wrote:
> Hello,
> 
> On Wed, Jul 22, 2015 at 08:28:39AM +0800, Baoquan He wrote:
> > I know this change makes code longer. PCPU_MAP_BUSY is better, I am gonna
> > repost with it.
> 
> While at it, can you also please add comment on top of the definition
> of PCPU_MAP_BUSY explaining what's going on?

Posted [patch v2 3/3] as you suggested.

Thanks a lot.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
