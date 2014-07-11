Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 55B186B0035
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 18:22:06 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id f8so355293wiw.16
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 15:22:05 -0700 (PDT)
Received: from mail-we0-x234.google.com (mail-we0-x234.google.com [2a00:1450:400c:c03::234])
        by mx.google.com with ESMTPS id p8si6486065wjb.170.2014.07.11.15.22.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 11 Jul 2014 15:22:05 -0700 (PDT)
Received: by mail-we0-f180.google.com with SMTP id k48so782691wev.39
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 15:22:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140711201054.GB18033@amd.pavel.ucw.cz>
References: <53B3D3AA.3000408@samsung.com>
	<x49y4wbu54y.fsf@segfault.boston.devel.redhat.com>
	<20140702184050.GA24583@infradead.org>
	<20140711201054.GB18033@amd.pavel.ucw.cz>
Date: Sat, 12 Jul 2014 01:22:04 +0300
Message-ID: <CACE9dm8TW1+7bq6hJiOmoAw+w+ZD8Ma=Sf6a5ZM2HZ5X1Lcifw@mail.gmail.com>
Subject: Re: IMA: kernel reading files opened with O_DIRECT
From: Dmitry Kasatkin <dmitry.kasatkin@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Christoph Hellwig <hch@infradead.org>, Jeff Moyer <jmoyer@redhat.com>, Dmitry Kasatkin <d.kasatkin@samsung.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, Al Viro <viro@zeniv.linux.org.uk>, Mimi Zohar <zohar@linux.vnet.ibm.com>, linux-security-module <linux-security-module@vger.kernel.org>, Greg KH <gregkh@linuxfoundation.org>

On 11 July 2014 23:10, Pavel Machek <pavel@ucw.cz> wrote:
> On Wed 2014-07-02 11:40:50, Christoph Hellwig wrote:
>> On Wed, Jul 02, 2014 at 11:55:41AM -0400, Jeff Moyer wrote:
>> > It's acceptable.
>>
>> It's not because it will then also affect other reads going on at the
>> same time.
>>
>> The whole concept of ima is just broken, and if you want to do these
>> sort of verification they need to happen inside the filesystem and not
>> above it.
>
> ...and doing it at filesystem layer would also permit verification of
> per-block (64KB? 1MB?) hashes.

Please design one single and the best universal filesystem which does it.

> Reading entire iso image when I run
> "file foo.iso" is anti-social..
>                                                                         Pavel

Please make the policy which does not make anti-social.

It is all about use-case.

- Dmitry

> --
> (english) http://www.livejournal.com/~pavelmachek
> (cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
