Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0D6376B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 12:03:11 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id z184so22523175pgd.0
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 09:03:11 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id n1si9963826pge.665.2017.11.24.09.03.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Nov 2017 09:03:09 -0800 (PST)
Date: Fri, 24 Nov 2017 09:03:07 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: XArray documentation
Message-ID: <20171124170307.GA681@bombadil.infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
 <20171124011607.GB3722@bombadil.infradead.org>
 <3543098.x2GeNdvaH7@merkaba>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <3543098.x2GeNdvaH7@merkaba>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Steigerwald <martin@lichtvoll.de>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>

On Fri, Nov 24, 2017 at 05:50:41PM +0100, Martin Steigerwald wrote:
> Matthew Wilcox - 24.11.17, 02:16:
> > ======
> > XArray
> > ======
> > 
> > Overview
> > ========
> > 
> > The XArray is an array of ULONG_MAX entries.  Each entry can be either
> > a pointer, or an encoded value between 0 and LONG_MAX.  It is efficient
> > when the indices used are densely clustered; hashing the object and
> > using the hash as the index will not perform well.  A freshly-initialised
> > XArray contains a NULL pointer at every index.  There is no difference
> > between an entry which has never been stored to and an entry which has most
> > recently had NULL stored to it.
> 
> I am no kernel developer (just provided a tiny bit of documentation a long 
> time ago)a?| but on reading into this, I missed:
> 
> What is it about? And what is it used for?
> 
> "Overview" appears to be already a description of the actual implementation 
> specifics, instead ofa?| well an overview.
> 
> Of course, I am sure you all know what it is fora?| but someone who wants to 
> learn about the kernel is likely to be confused by such a start.

Hi Martin,

Thank you for your comment.  I'm clearly too close to it because even
after reading your useful critique, I'm not sure what to change.  Please
help me!

Maybe it's that I've described the abstraction as if it's the
implementation and put too much detail into the overview.  This might
be clearer?

The XArray is an abstract data type which behaves like an infinitely
large array of pointers.  The index into the array is an unsigned long.
A freshly-initialised XArray contains a NULL pointer at every index.

----
and then move all this information into later paragraphs:

There is no difference between an entry which has never been stored to
and an entry which has most recently had NULL stored to it.
Each entry in the array can be either a pointer, or an
encoded value between 0 and LONG_MAX.
While you can use any index, the implementation is efficient when the
indices used are densely clustered; hashing the object and using the
hash as the index will not perform well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
