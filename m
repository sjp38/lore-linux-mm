Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id B3C6B9003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 09:52:40 -0400 (EDT)
Received: by ykax123 with SMTP id x123so193354116yka.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 06:52:40 -0700 (PDT)
Received: from mail-yk0-x22b.google.com (mail-yk0-x22b.google.com. [2607:f8b0:4002:c07::22b])
        by mx.google.com with ESMTPS id p63si1101215ywp.109.2015.07.22.06.52.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 06:52:39 -0700 (PDT)
Received: by ykdu72 with SMTP id u72so192783050ykd.2
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 06:52:39 -0700 (PDT)
Date: Wed, 22 Jul 2015 09:52:37 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/3] perpuc: check pcpu_first_chunk and
 pcpu_reserved_chunk to avoid handling them twice
Message-ID: <20150722135237.GJ15934@mtj.duckdns.org>
References: <1437404130-5188-1-git-send-email-bhe@redhat.com>
 <1437404130-5188-2-git-send-email-bhe@redhat.com>
 <20150721152840.GG15934@mtj.duckdns.org>
 <20150722000357.GA1834@dhcp-17-102.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150722000357.GA1834@dhcp-17-102.nay.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On Wed, Jul 22, 2015 at 08:03:57AM +0800, Baoquan He wrote:
> Yes, dyn_size can't be zero. But in pcpu_setup_first_chunk(), the local
> variable dyn_size could be zero caused by below code:
> 
> if (ai->reserved_size) {
>                 schunk->free_size = ai->reserved_size;
>                 pcpu_reserved_chunk = schunk;
>                 pcpu_reserved_chunk_limit = ai->static_size +
> ai->reserved_size;
>         } else {
>                 schunk->free_size = dyn_size;
>                 dyn_size = 0;                   /* dynamic area covered
> */
>         }
> 
> So if no reserved_size dyn_size is assigned to zero, and is checked to
> see if dchunk need be created in below code:

Hmmm... but then pcpu_reserved_chunk is NULL so there still is no
duplicate on the list, no?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
