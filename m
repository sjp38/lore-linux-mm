Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 352C36B025E
	for <linux-mm@kvack.org>; Sat, 10 Dec 2016 09:46:05 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id l20so34838704qta.3
        for <linux-mm@kvack.org>; Sat, 10 Dec 2016 06:46:05 -0800 (PST)
Received: from frisell.zx2c4.com (frisell.zx2c4.com. [192.95.5.64])
        by mx.google.com with ESMTPS id 18si22577788qtq.221.2016.12.10.06.46.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 10 Dec 2016 06:46:04 -0800 (PST)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id 4ceb36ba
	for <linux-mm@kvack.org>;
	Sat, 10 Dec 2016 14:40:13 +0000 (UTC)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id 2717b1ab (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
	for <linux-mm@kvack.org>;
	Sat, 10 Dec 2016 14:40:11 +0000 (UTC)
Received: by mail-lf0-f52.google.com with SMTP id t196so18449898lff.3
        for <linux-mm@kvack.org>; Sat, 10 Dec 2016 06:45:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161210053711.GB27951@gondor.apana.org.au>
References: <20161209230851.GB64048@google.com> <CALCETrW=+3u3P8Xva+0ck9=fr-mD6azPtTkOQ3uQO+GoOA6FcQ@mail.gmail.com>
 <20161210053711.GB27951@gondor.apana.org.au>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Sat, 10 Dec 2016 15:45:56 +0100
Message-ID: <CAHmME9pzT=bxuEVVGDOJkm2PaEAVjbo=8na7URy=g-1sKvv0yw@mail.gmail.com>
Subject: Re: [kernel-hardening] Re: Remaining crypto API regressions with CONFIG_VMAP_STACK
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Andy Lutomirski <luto@amacapital.net>, Eric Biggers <ebiggers3@gmail.com>, linux-crypto@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Stephan Mueller <smueller@chronox.de>

Hi Herbert,

On Sat, Dec 10, 2016 at 6:37 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> As for AEAD we never had a sync interface to begin with and I
> don't think I'm going to add one.

That's too bad to hear. I hope you'll reconsider. Modern cryptographic
design is heading more and more in the direction of using AEADs for
interesting things, and having a sync interface would be a lot easier
for implementing these protocols. In the same way many protocols need
a hash of some data, now protocols often want some particular data
encrypted with an AEAD using a particular key and nonce and AD. One
protocol that comes to mind is Noise [1].

I know that in my own [currently external to the tree] kernel code, I
just forego the use of the crypto API all together, and one of the
primary reasons for that is lack of a sync interface for AEADs. When I
eventually send this upstream, presumably everyone will want me to use
the crypto API, and having a sync AEAD interface would be personally
helpful for that. I guess I could always write the sync interface
myself, but I imagine you'd prefer having the design control etc.

Jason


[1] http://noiseprotocol.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
