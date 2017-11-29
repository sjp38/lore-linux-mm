Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9B9E16B0253
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 00:06:10 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id j3so1578278pfh.16
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 21:06:10 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c184sor270276pfc.35.2017.11.28.21.06.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Nov 2017 21:06:09 -0800 (PST)
Date: Tue, 28 Nov 2017 21:06:06 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: WARNING: suspicious RCU usage (3)
Message-ID: <20171129050606.GF24001@zzz.localdomain>
References: <94eb2c03c9bcc3b127055f11171d@google.com>
 <20171128133026.cf03471c99d7a0c827c5a21c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171128133026.cf03471c99d7a0c827c5a21c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: syzbot <bot+73a7bec1bc0f4fc0512a246334081f8c671762a8@syzkaller.appspotmail.com>, cl@linux.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, rientjes@google.com, syzkaller-bugs@googlegroups.com, "Paul E. McKenney" <paulmck@us.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>

On Tue, Nov 28, 2017 at 01:30:26PM -0800, Andrew Morton wrote:
> 
> It looks like blkcipher_walk_done() passed a bad address to kfree().
> 

Indeed, it's freeing uninitialized memory because the Salsa20 algorithms are
using the blkcipher_walk API incorrectly.  I've sent a patch to fix it:

"crypto: salsa20 - fix blkcipher_walk API usage"

I am not sure why the bug reports show up as "suspicious RCU usage", though.

There were also a few other syzbot reports of this same underlying bug; I marked
them as duplicates of this one.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
