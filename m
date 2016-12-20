Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 418296B034D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 14:22:36 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id n68so116870917itn.4
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 11:22:36 -0800 (PST)
Received: from mail-io0-x241.google.com (mail-io0-x241.google.com. [2607:f8b0:4001:c06::241])
        by mx.google.com with ESMTPS id v64si14250547itd.3.2016.12.20.11.22.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 11:22:35 -0800 (PST)
Received: by mail-io0-x241.google.com with SMTP id p13so23503024ioi.0
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 11:22:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161205121131.3c1d9ad8452d5e09247336e4@linux-foundation.org>
References: <20161129182010.13445.31256.stgit@localhost.localdomain>
 <CAKgT0UchMkvsboO23R332j96=yumL7=oSSm97zqJ5-v30_SgCw@mail.gmail.com> <20161205121131.3c1d9ad8452d5e09247336e4@linux-foundation.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 20 Dec 2016 11:22:34 -0800
Message-ID: <CAKgT0UfgY089jdzXexB87yPOdEFhAAi=au8b4RX2LnHNOM_=kw@mail.gmail.com>
Subject: Re: [mm PATCH 0/3] Page fragment updates
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Netdev <netdev@vger.kernel.org>, Eric Dumazet <edumazet@google.com>, David Miller <davem@davemloft.net>, Jeff Kirsher <jeffrey.t.kirsher@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Dec 5, 2016 at 12:11 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon, 5 Dec 2016 09:01:12 -0800 Alexander Duyck <alexander.duyck@gmail.com> wrote:
>
>> On Tue, Nov 29, 2016 at 10:23 AM, Alexander Duyck
>> <alexander.duyck@gmail.com> wrote:
>> > This patch series takes care of a few cleanups for the page fragments API.
>> >
>> > ...
>>
>> It's been about a week since I submitted this series.  Just wanted to
>> check in and see if anyone had any feedback or if this is good to be
>> accepted for 4.10-rc1 with the rest of the set?
>
> Looks good to me.  I have it all queued for post-4.9 processing.

So I guess there is a small bug in the first patch in that I was
comparing a pointer to to 0 instead of NULL.  Just wondering if I
should resubmit the first patch, the whole series, or if I need to
just submit an incremental patch.

Thanks.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
