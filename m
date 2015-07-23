Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 5A0C59003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 21:56:30 -0400 (EDT)
Received: by qgii95 with SMTP id i95so80580459qgi.2
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 18:56:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f5si3932387qhc.72.2015.07.22.18.56.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 18:56:29 -0700 (PDT)
Date: Thu, 23 Jul 2015 09:56:22 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH 2/3] perpuc: check pcpu_first_chunk and
 pcpu_reserved_chunk to avoid handling them twice
Message-ID: <20150723015622.GA8369@dhcp-17-102.nay.redhat.com>
References: <1437404130-5188-1-git-send-email-bhe@redhat.com>
 <1437404130-5188-2-git-send-email-bhe@redhat.com>
 <20150721152840.GG15934@mtj.duckdns.org>
 <20150722000357.GA1834@dhcp-17-102.nay.redhat.com>
 <20150722135237.GJ15934@mtj.duckdns.org>
 <20150722142900.GA1737@dhcp-17-102.nay.redhat.com>
 <20150722143729.GM15934@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150722143729.GM15934@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/22/15 at 10:37am, Tejun Heo wrote:
> On Wed, Jul 22, 2015 at 10:29:00PM +0800, Baoquan He wrote:
> > > > So if no reserved_size dyn_size is assigned to zero, and is checked to
> > > > see if dchunk need be created in below code:
> > > 
> > > Hmmm... but then pcpu_reserved_chunk is NULL so there still is no
> > > duplicate on the list, no?
> > 
> > Yes, you are quite right. I was mistaken. So NACK this patch.
> 
> But, yeah, it'd be great if we can add a WARN_ON() to ensure that this
> really doesn't happen along with some comments.

Posted [patch v3 2/3] as you suggested.

Thanks a lot!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
