Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 915236B0031
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 09:03:11 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id f8so3318681wiw.0
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 06:03:11 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id xm18si15620533wib.3.2014.07.15.06.03.09
        for <linux-mm@kvack.org>;
        Tue, 15 Jul 2014 06:03:09 -0700 (PDT)
Date: Tue, 15 Jul 2014 15:03:08 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: IMA: kernel reading files opened with O_DIRECT
Message-ID: <20140715130308.GA4109@amd.pavel.ucw.cz>
References: <53B3D3AA.3000408@samsung.com>
 <x49y4wbu54y.fsf@segfault.boston.devel.redhat.com>
 <20140702184050.GA24583@infradead.org>
 <20140711201054.GB18033@amd.pavel.ucw.cz>
 <CACE9dm8TW1+7bq6hJiOmoAw+w+ZD8Ma=Sf6a5ZM2HZ5X1Lcifw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACE9dm8TW1+7bq6hJiOmoAw+w+ZD8Ma=Sf6a5ZM2HZ5X1Lcifw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Kasatkin <dmitry.kasatkin@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jeff Moyer <jmoyer@redhat.com>, Dmitry Kasatkin <d.kasatkin@samsung.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, Al Viro <viro@zeniv.linux.org.uk>, Mimi Zohar <zohar@linux.vnet.ibm.com>, linux-security-module <linux-security-module@vger.kernel.org>, Greg KH <gregkh@linuxfoundation.org>

On Sat 2014-07-12 01:22:04, Dmitry Kasatkin wrote:
> On 11 July 2014 23:10, Pavel Machek <pavel@ucw.cz> wrote:
> > On Wed 2014-07-02 11:40:50, Christoph Hellwig wrote:
> >> On Wed, Jul 02, 2014 at 11:55:41AM -0400, Jeff Moyer wrote:
> >> > It's acceptable.
> >>
> >> It's not because it will then also affect other reads going on at the
> >> same time.
> >>
> >> The whole concept of ima is just broken, and if you want to do these
> >> sort of verification they need to happen inside the filesystem and not
> >> above it.
> >
> > ...and doing it at filesystem layer would also permit verification of
> > per-block (64KB? 1MB?) hashes.
> 
> Please design one single and the best universal filesystem which
> does it.

Given the overhead whole-file hashing has, you don't need single best
operating system. All you need it either ext4 or btrfs.. depending on
when you want it in production.

									Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
