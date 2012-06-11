Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 0358F6B0138
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 10:37:34 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so9046362obb.14
        for <linux-mm@kvack.org>; Mon, 11 Jun 2012 07:37:33 -0700 (PDT)
Message-ID: <1339425523.4999.56.camel@lappy>
Subject: Re: [PATCH v3 04/10] mm: frontswap: split out
 __frontswap_unuse_pages
From: Sasha Levin <levinsasha928@gmail.com>
Date: Mon, 11 Jun 2012 16:38:43 +0200
In-Reply-To: <CAPbh3ruqk+dU4C8b=mSko+2EjumrswgkO6CUp73=8thvLNAA8A@mail.gmail.com>
References: <1339325468-30614-1-git-send-email-levinsasha928@gmail.com>
	 <1339325468-30614-5-git-send-email-levinsasha928@gmail.com>
	 <4FD5856C.5060708@kernel.org> <1339410650.4999.38.camel@lappy>
	 <e82083d1-af9f-4766-992c-926413f02423@default>
	 <CAPbh3ruqk+dU4C8b=mSko+2EjumrswgkO6CUp73=8thvLNAA8A@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: konrad@darnok.org
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 2012-06-11 at 10:31 -0400, Konrad Rzeszutek Wilk wrote:
> > I'm not sure of the correct kernel style but I like the fact
> > that assert_spin_locked both documents the lock requirement and tests
> > it at runtime.
> 
> The kernel style is to do "
> 3) Separate your changes.
> 
> Separate _logical changes_ into a single patch file.
> "
> 
> So it is fine, but it should be in its own patch. 

It is one logical change: I've moved a block of code that has to be
locked in the swap mutex into it's own function, adding the spinlock
assertion isn't new code, nor it relates to any new code. It's there to
assert that what happened before still happens now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
