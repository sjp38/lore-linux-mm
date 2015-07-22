Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id AB7C16B0257
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 10:37:32 -0400 (EDT)
Received: by ykdu72 with SMTP id u72so193979235ykd.2
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 07:37:32 -0700 (PDT)
Received: from mail-yk0-x235.google.com (mail-yk0-x235.google.com. [2607:f8b0:4002:c07::235])
        by mx.google.com with ESMTPS id z187si1222274ykz.12.2015.07.22.07.37.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 07:37:31 -0700 (PDT)
Received: by ykdu72 with SMTP id u72so193978869ykd.2
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 07:37:31 -0700 (PDT)
Date: Wed, 22 Jul 2015 10:37:29 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/3] perpuc: check pcpu_first_chunk and
 pcpu_reserved_chunk to avoid handling them twice
Message-ID: <20150722143729.GM15934@mtj.duckdns.org>
References: <1437404130-5188-1-git-send-email-bhe@redhat.com>
 <1437404130-5188-2-git-send-email-bhe@redhat.com>
 <20150721152840.GG15934@mtj.duckdns.org>
 <20150722000357.GA1834@dhcp-17-102.nay.redhat.com>
 <20150722135237.GJ15934@mtj.duckdns.org>
 <20150722142900.GA1737@dhcp-17-102.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150722142900.GA1737@dhcp-17-102.nay.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 22, 2015 at 10:29:00PM +0800, Baoquan He wrote:
> > > So if no reserved_size dyn_size is assigned to zero, and is checked to
> > > see if dchunk need be created in below code:
> > 
> > Hmmm... but then pcpu_reserved_chunk is NULL so there still is no
> > duplicate on the list, no?
> 
> Yes, you are quite right. I was mistaken. So NACK this patch.

But, yeah, it'd be great if we can add a WARN_ON() to ensure that this
really doesn't happen along with some comments.

Thanks!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
