Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 129F76B00C8
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 09:56:25 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id y10so2798244wgg.20
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 06:56:25 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id ht3si6766109wjb.144.2014.06.13.06.56.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Jun 2014 06:56:24 -0700 (PDT)
Date: Fri, 13 Jun 2014 14:56:15 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: mm/fs: gpf when shrinking slab
Message-ID: <20140613135615.GG18016@ZenIV.linux.org.uk>
References: <539AF460.4000400@oracle.com>
 <539AF4A6.9060707@oracle.com>
 <20140613130026.GF18016@ZenIV.linux.org.uk>
 <539AFCBF.1040505@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <539AFCBF.1040505@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Christoph Lameter <cl@gentwo.org>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>

On Fri, Jun 13, 2014 at 09:29:35AM -0400, Sasha Levin wrote:
> On 06/13/2014 09:00 AM, Al Viro wrote:
> > On Fri, Jun 13, 2014 at 08:55:02AM -0400, Sasha Levin wrote:
> >> Hand too fast on the trigger... sorry.
> >>
> >> It happened while fuzzing inside a KVM tools guest on the latest -next kernel. Seems
> >> to be pretty difficult to reproduce.
> > 
> > Does that kernel contain c2338f?
> > 
> 
> Nope, it didn't.

Try to reproduce with it, please...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
