Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3F40F6B0261
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 20:28:46 -0400 (EDT)
Received: by qgeu79 with SMTP id u79so40465439qge.1
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 17:28:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d13si30423013qka.37.2015.07.21.17.28.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 17:28:45 -0700 (PDT)
Date: Wed, 22 Jul 2015 08:28:39 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH 3/3] percpu: add macro PCPU_CHUNK_AREA_IN_USE
Message-ID: <20150722002839.GC1834@dhcp-17-102.nay.redhat.com>
References: <1437404130-5188-1-git-send-email-bhe@redhat.com>
 <1437404130-5188-3-git-send-email-bhe@redhat.com>
 <20150721153019.GH15934@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150721153019.GH15934@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Tejun,

On 07/21/15 at 11:30am, Tejun Heo wrote:
> On Mon, Jul 20, 2015 at 10:55:30PM +0800, Baoquan He wrote:
> > chunk->map[] contains <offset|in-use flag> of each area. Now add a
> > new macro PCPU_CHUNK_AREA_IN_USE and use it as the in-use flag to
> > replace all magic number '1'.
> > 
> > Signed-off-by: Baoquan He <bhe@redhat.com>
> 
> idk, maybe.  Can you at least go for something shorter?  PCPU_MAP_BUSY
> or whatever?

Thanks for suggestion.

I know this change makes code longer. PCPU_MAP_BUSY is better, I am gonna
repost with it.

Thanks
Baoquan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
