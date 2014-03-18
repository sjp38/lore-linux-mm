Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 74FE76B011F
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 19:10:53 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so7772863pdi.30
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 16:10:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id xn1si11635217pbc.248.2014.03.18.16.10.52
        for <linux-mm@kvack.org>;
        Tue, 18 Mar 2014 16:10:52 -0700 (PDT)
Date: Tue, 18 Mar 2014 16:10:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG -next] "mm: per-thread vma caching fix 5" breaks s390
Message-Id: <20140318161050.ab184d30edf4b2446a2060de@linux-foundation.org>
In-Reply-To: <CA+8MBbKaaYXNV_XZNRp=wn-+3Mqd4+JVoXn_d+eo=PQR17i1SQ@mail.gmail.com>
References: <20140318124107.GA24890@osiris>
	<CA+8MBbKaaYXNV_XZNRp=wn-+3Mqd4+JVoXn_d+eo=PQR17i1SQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Davidlohr Bueso <davidlohr@hp.com>, Michel Lespinasse <walken@google.com>, Sasha Levin <sasha.levin@oracle.com>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Tue, 18 Mar 2014 16:06:59 -0700 Tony Luck <tony.luck@gmail.com> wrote:

> On Tue, Mar 18, 2014 at 5:41 AM, Heiko Carstens
> <heiko.carstens@de.ibm.com> wrote:
> > Given that this is just an addon patch to Davidlohr's "mm: per-thread
> > vma caching" patch I was wondering if something in there is architecture
> > specific.
> > But it doesn't look like that. So I'm wondering if this only breaks on
> > s390?
> 
> I'm seeing this same BUG_ON() on ia64 (when trying out next-20140318)

-next is missing
http://ozlabs.org/~akpm/mmots/broken-out/mm-per-thread-vma-caching-fix-6.patch.
Am presently trying to cook up an mmotm for tomorrow's -next.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
