Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2F3B76B00B8
	for <linux-mm@kvack.org>; Mon, 25 May 2015 03:33:40 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so64592179pdb.0
        for <linux-mm@kvack.org>; Mon, 25 May 2015 00:33:39 -0700 (PDT)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com. [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id qg8si14998669pdb.230.2015.05.25.00.33.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 May 2015 00:33:39 -0700 (PDT)
Received: by pdbki1 with SMTP id ki1so22929378pdb.1
        for <linux-mm@kvack.org>; Mon, 25 May 2015 00:33:39 -0700 (PDT)
Date: Mon, 25 May 2015 16:34:00 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zram: check compressor name before setting it
Message-ID: <20150525073400.GD555@swordfish>
References: <1432283515-2005-1-git-send-email-m.jabrzyk@samsung.com>
 <20150522085523.GA709@swordfish>
 <555EF30C.60108@samsung.com>
 <20150522124411.GA3793@swordfish>
 <555F2E7C.4090707@samsung.com>
 <20150525061838.GB555@swordfish>
 <5562CBF4.2090007@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5562CBF4.2090007@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcin Jabrzyk <m.jabrzyk@samsung.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, minchan@kernel.org, ngupta@vflare.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com

On (05/25/15 09:15), Marcin Jabrzyk wrote:
[..]
> >
> I'm perfectly fine with this solution. It just does what
> I'd expect.

cool, let's hear from Minchan.

btw, if we decide to move on, how do you guys want to route
it? do you want Marcin (I don't mind)  or me  (of course,
with the appropriate credit to Marcin) to submit it?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
