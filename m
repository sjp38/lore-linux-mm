Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id A99986B0035
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 16:11:22 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id a1so825837wgh.11
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 13:11:19 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id l3si5982522wjx.149.2014.07.11.13.11.04
        for <linux-mm@kvack.org>;
        Fri, 11 Jul 2014 13:11:05 -0700 (PDT)
Date: Fri, 11 Jul 2014 22:10:54 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: IMA: kernel reading files opened with O_DIRECT
Message-ID: <20140711201054.GB18033@amd.pavel.ucw.cz>
References: <53B3D3AA.3000408@samsung.com>
 <x49y4wbu54y.fsf@segfault.boston.devel.redhat.com>
 <20140702184050.GA24583@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140702184050.GA24583@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Moyer <jmoyer@redhat.com>, Dmitry Kasatkin <d.kasatkin@samsung.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, viro@ZenIV.linux.org.uk, Mimi Zohar <zohar@linux.vnet.ibm.com>, linux-security-module <linux-security-module@vger.kernel.org>, Greg KH <gregkh@linuxfoundation.org>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>

On Wed 2014-07-02 11:40:50, Christoph Hellwig wrote:
> On Wed, Jul 02, 2014 at 11:55:41AM -0400, Jeff Moyer wrote:
> > It's acceptable.
> 
> It's not because it will then also affect other reads going on at the
> same time.
> 
> The whole concept of ima is just broken, and if you want to do these
> sort of verification they need to happen inside the filesystem and not
> above it.

...and doing it at filesystem layer would also permit verification of
per-block (64KB? 1MB?) hashes. Reading entire iso image when I run
"file foo.iso" is anti-social..
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
