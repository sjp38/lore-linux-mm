Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 62E586B0075
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 08:48:33 -0400 (EDT)
Received: by mail-ie0-f175.google.com with SMTP id x19so696834ier.34
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 05:48:33 -0700 (PDT)
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com. [32.97.110.152])
        by mx.google.com with ESMTPS id v7si4416578ice.90.2014.07.16.05.48.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 05:48:31 -0700 (PDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zohar@linux.vnet.ibm.com>;
	Wed, 16 Jul 2014 06:48:30 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 1E7381FF001E
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 06:48:27 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp08026.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s6GClFLe1507814
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 14:47:15 +0200
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s6GCmRj6020284
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 06:48:27 -0600
Message-ID: <1405514905.1466.34.camel@dhcp-9-2-203-236.watson.ibm.com>
Subject: Re: IMA: kernel reading files opened with O_DIRECT
From: Mimi Zohar <zohar@linux.vnet.ibm.com>
Date: Wed, 16 Jul 2014 08:48:25 -0400
In-Reply-To: <20140715130308.GA4109@amd.pavel.ucw.cz>
References: <53B3D3AA.3000408@samsung.com>
	 <x49y4wbu54y.fsf@segfault.boston.devel.redhat.com>
	 <20140702184050.GA24583@infradead.org>
	 <20140711201054.GB18033@amd.pavel.ucw.cz>
	 <CACE9dm8TW1+7bq6hJiOmoAw+w+ZD8Ma=Sf6a5ZM2HZ5X1Lcifw@mail.gmail.com>
	 <20140715130308.GA4109@amd.pavel.ucw.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Christoph Hellwig <hch@infradead.org>, Jeff Moyer <jmoyer@redhat.com>, Dmitry Kasatkin <d.kasatkin@samsung.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, Al Viro <viro@zeniv.linux.org.uk>, linux-security-module <linux-security-module@vger.kernel.org>, Greg KH <gregkh@linuxfoundation.org>, Lukas Czerner <lczerner@redhat.kvack.org>

On Tue, 2014-07-15 at 15:03 +0200, Pavel Machek wrote: 
> On Sat 2014-07-12 01:22:04, Dmitry Kasatkin wrote:
> > On 11 July 2014 23:10, Pavel Machek <pavel@ucw.cz> wrote:
> > > On Wed 2014-07-02 11:40:50, Christoph Hellwig wrote:
> > >> On Wed, Jul 02, 2014 at 11:55:41AM -0400, Jeff Moyer wrote:
> > >> > It's acceptable.
> > >>
> > >> It's not because it will then also affect other reads going on at the
> > >> same time.
> > >>
> > >> The whole concept of ima is just broken, and if you want to do these
> > >> sort of verification they need to happen inside the filesystem and not
> > >> above it.

Agreed, maintaining the file's integrity hash should be done at the
filesystem layer.  IMA would then be relegated to using the integrity
information to maintain the measurement list and enforce local file
integrity.

> > > ...and doing it at filesystem layer would also permit verification of
> > > per-block (64KB? 1MB?) hashes.
> > 
> > Please design one single and the best universal filesystem which
> > does it.
> 
> Given the overhead whole-file hashing has, you don't need single best
> operating system. All you need it either ext4 or btrfs.. depending on
> when you want it in production.

Mike Halcrow will be leading a discussion on EXT4 Encryption at LSS
http://kernsec.org/wiki/index.php/Linux_Security_Summit_2014/Abstracts/Halcrow.
One of the discussion topics will be the storage of file metadata
integrity.  (Lukas Czerner's work.)  Hope you'll be able to attend.

Mimi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
