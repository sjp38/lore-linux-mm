Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3D06E6B0032
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 23:08:01 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id rd3so22826292pab.3
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 20:08:01 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id la4si4245508pbc.14.2015.01.27.20.08.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 Jan 2015 20:08:00 -0800 (PST)
Received: by mail-pa0-f54.google.com with SMTP id eu11so22824718pac.13
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 20:08:00 -0800 (PST)
Date: Wed, 28 Jan 2015 13:07:57 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 1/2] zram: free meta out of init_lock
Message-ID: <20150128040757.GA577@swordfish>
References: <20150126141709.GA985@swordfish>
 <20150126160007.GC528@blaptop>
 <20150127021704.GA665@swordfish>
 <20150127031823.GA16797@blaptop>
 <20150127040305.GB665@swordfish>
 <20150128001526.GA25828@blaptop>
 <20150128002203.GB25828@blaptop>
 <20150128020759.GA343@swordfish>
 <20150128025707.GB32712@blaptop>
 <20150128035354.GA7790@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150128035354.GA7790@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>

On (01/28/15 12:53), Sergey Senozhatsky wrote:
> > So, I want to go with srcu. Do you agree? or another suggestion?
> 
> yes, I think we need to take a second look on srcu approach.
> 

... or we can ask lockdep to stop false alarming us and leave it as is.
I wouldn't say that ->init_lock is so hard to understand.
just as an option.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
