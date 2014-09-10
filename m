Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0B3106B0036
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 08:24:50 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id c11so4951836lbj.23
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 05:24:50 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id oy5si21426499lbb.15.2014.09.10.05.24.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Sep 2014 05:24:48 -0700 (PDT)
Message-ID: <5410430E.5030804@parallels.com>
Date: Wed, 10 Sep 2014 16:24:46 +0400
From: Maxim Patlasov <mpatlasov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] fuse: fix regression in fuse_get_user_pages()
References: <20140903100826.23218.95122.stgit@localhost.localdomain> <20140910095115.GA7441@tucsk.piliscsaba.szeredi.hu>
In-Reply-To: <20140910095115.GA7441@tucsk.piliscsaba.szeredi.hu>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: viro@zeniv.linux.org.uk, fuse-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, werner.baumann@onlinehome.de

On 09/10/2014 01:51 PM, Miklos Szeredi wrote:
> On Wed, Sep 03, 2014 at 02:10:23PM +0400, Maxim Patlasov wrote:
>> Hi,
>>
>> The patchset fixes a regression introduced by the following commits:
>>
>> c7f3888ad7f0 ("switch iov_iter_get_pages() to passing maximal number of pages")
>> c9c37e2e6378 ("fuse: switch to iov_iter_get_pages()")
>>
> Hmm, instead of reverting to passing maxbytes *instead* of maxpages, I think the
> right fix is to *add* the maxbytes argument.
>
> Just maxbytes alone doesn't have enough information in it.  E.g. 4096 contiguous
> bytes could occupy 1 or 2 pages, depending on the starting offset.
Yes, you are right. I missed that c7f3888ad7f0 fixed a subtle bug in 
get_pages_iovec().

>
> So how about the following (untested) patch?
Your patch works fine in my tests.

Thanks,
Maxim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
