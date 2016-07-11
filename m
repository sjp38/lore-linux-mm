Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id D865B6B0005
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 09:18:21 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id a5so250282570vkc.1
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 06:18:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o129si523741qkd.50.2016.07.11.06.18.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 06:18:21 -0700 (PDT)
Date: Mon, 11 Jul 2016 09:18:19 -0400
From: Mike Snitzer <snitzer@redhat.com>
Subject: Re: [4.7.0rc6] Page Allocation Failures with dm-crypt
Message-ID: <20160711131818.GA28102@redhat.com>
References: <28dc911645dce0b5741c369dd7650099@mail.ud19.udmedia.de>
 <e7af885e08e1ced4f75313bfdfda166d@mail.ud19.udmedia.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e7af885e08e1ced4f75313bfdfda166d@mail.ud19.udmedia.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Dahl <ml_linux-kernel@binary-island.eu>
Cc: linux-mm@kvack.org, dm-devel@redhat.com, linux-kernel@vger.kernel.org

On Mon, Jul 11 2016 at  4:31am -0400,
Matthias Dahl <ml_linux-kernel@binary-island.eu> wrote:

> Hello,
> 
> I made a few more tests and here my observations:
> 
> - kernels 4.4.8 and 4.5.5 show the same behavior
> 
> - the moment dd starts, memory usage spikes rapidly and within a just
>   a few seconds has filled up all 32 GiB of RAM
> 
> - dd w/ direct i/o works just fine
> 
> - mkfs.ext4 unfortunately shows the same behavior as dd w/o direct i/o
>   and such makes creation of an ext4 fs on dm-crypt a game of luck
> 
>   (much more exposed so with e2fsprogs 1.43.1)
> 
> I am kind of puzzled that this bug has seemingly gone so long unnoticed
> since it is rather severe and makes dm-crypt unusable to a certain
> degree
> for fs encryption (or at least the initial creation of the fs). Am I
> missing something here or doing something terribly stupid?

Not clear.  Certainly haven't had any reports of memory leaks with
dm-crypt.  Something must explain the execessive nature of your leak but
it isn't a known issue.

Have you tried running with kmemleak enabled?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
