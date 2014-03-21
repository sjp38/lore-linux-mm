Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f182.google.com (mail-vc0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id AAB426B027A
	for <linux-mm@kvack.org>; Fri, 21 Mar 2014 16:39:03 -0400 (EDT)
Received: by mail-vc0-f182.google.com with SMTP id ks9so3260949vcb.27
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 13:39:03 -0700 (PDT)
Received: from mail-vc0-x22f.google.com (mail-vc0-x22f.google.com [2607:f8b0:400c:c03::22f])
        by mx.google.com with ESMTPS id rx10si1429227vdc.78.2014.03.21.13.39.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Mar 2014 13:39:02 -0700 (PDT)
Received: by mail-vc0-f175.google.com with SMTP id lh14so3187517vcb.6
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 13:39:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140319102711.84f68cdb4a7b7acfd945fe74@canb.auug.org.au>
References: <20140318124107.GA24890@osiris>
	<CA+8MBbKaaYXNV_XZNRp=wn-+3Mqd4+JVoXn_d+eo=PQR17i1SQ@mail.gmail.com>
	<20140318161050.ab184d30edf4b2446a2060de@linux-foundation.org>
	<20140319102711.84f68cdb4a7b7acfd945fe74@canb.auug.org.au>
Date: Fri, 21 Mar 2014 13:39:02 -0700
Message-ID: <CA+8MBbL849jdqGsFuS1Wu296m3=MDGAz9gef9A102pbfm5OLtw@mail.gmail.com>
Subject: Re: [BUG -next] "mm: per-thread vma caching fix 5" breaks s390
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Davidlohr Bueso <davidlohr@hp.com>, Michel Lespinasse <walken@google.com>, Sasha Levin <sasha.levin@oracle.com>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>

Problem is no longer present in next-20140321.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
