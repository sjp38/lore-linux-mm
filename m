Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5E09D6B042B
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 17:12:13 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id d185so195650975pgc.2
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 14:12:13 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id s17si4920990pgi.404.2017.02.15.14.12.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 14:12:12 -0800 (PST)
Date: Wed, 15 Feb 2017 22:12:08 +0000
From: Giovanni Cabiddu <giovanni.cabiddu@intel.com>
Subject: Re: [RFC PATCH v1 1/1] mm: zswap - Add crypto acomp/scomp framework
 support
Message-ID: <20170215221208.GA820@silv-gc1.ir.intel.com>
References: <1487086821-5880-1-git-send-email-Mahipal.Challa@cavium.com>
 <1487086821-5880-2-git-send-email-Mahipal.Challa@cavium.com>
 <CAC8qmcCt8VEX6QSSL35isN-nEvH-AJ2MAJHZy0TigxftsQN2jA@mail.gmail.com>
 <58A45E4A.8080508@caviumnetworks.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58A45E4A.8080508@caviumnetworks.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Narayana Prasad Athreya <pathreya@caviumnetworks.com>
Cc: Seth Jennings <sjenning@redhat.com>, Mahipal Challa <mahipalreddy2006@gmail.com>, herbert@gondor.apana.org.au, davem@davemloft.net, linux-crypto@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, pathreya@cavium.com, vnair@cavium.com, Mahipal Challa <Mahipal.Challa@cavium.com>, Vishnu Nair <Vishnu.Nair@cavium.com>

On Wed, Feb 15, 2017 at 07:27:30PM +0530, Narayana Prasad Athreya wrote:
> > I assume all of these crypto_acomp_[compress|decompress] calls are
> > actually synchronous,
> > not asynchronous as the name suggests.  Otherwise, this would blow up
> > quite spectacularly
> > since all the resources we use in the call get derefed/unmapped below.
> > 
> > Could an async algorithm be implement/used that would break this assumption?
> 
> The callback is set to NULL using acomp_request_set_callback(). This implies
> synchronous mode of operation. So the underlying implementation must
> complete the operation synchronously.
This assumption is not correct. An asynchronous implementation, when
it finishes processing a request, will call acomp_request_complete() which
in turn calls the callback.
If the callback is set to NULL, this function will dereference a NULL
pointer.

Regards,

-- 
Giovanni 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
