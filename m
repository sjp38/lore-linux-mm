Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1CDD26B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 09:28:00 -0500 (EST)
Received: by ywa17 with SMTP id 17so6955115ywa.14
        for <linux-mm@kvack.org>; Mon, 07 Nov 2011 06:27:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111107135823.3a7cdc53@lxorguk.ukuu.org.uk>
References: <1320614101.3226.5.camel@offbook> <20111107112952.GB25130@tango.0pointer.de>
 <1320675607.2330.0.camel@offworld> <20111107135823.3a7cdc53@lxorguk.ukuu.org.uk>
From: Kay Sievers <kay.sievers@vrfy.org>
Date: Mon, 7 Nov 2011 15:27:36 +0100
Message-ID: <CAPXgP117Wkgvf1kDukjWt9yOye8xArpyX29xx36NT++s8TS5Rw@mail.gmail.com>
Subject: Re: [RFC PATCH] tmpfs: support user quotas
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Davidlohr Bueso <dave@gnu.org>, Lennart Poettering <mzxreary@0pointer.de>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, Nov 7, 2011 at 14:58, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
>> Right, rlimit approach guarantees a simple way of dealing with users
>> across all tmpfs instances.
>
> Which is almost certainly not what you want to happen. Think about direct
> rendering.
>
> For simple stuff tmpfs already supports size/nr_blocks/nr_inodes mount
> options so you can mount private resource constrained tmpfs objects
> already without kernel changes. No rlimit hacks needed - and rlimit is
> the wrong API anyway.

What part of the message did you read? This is about _per_user_
limits, not global limits!

Any untrusted user can fill /dev/shm today and DOS many services that
way on any machine out there. Same for /tmp when it's a tmpfs, or
/run/user. This is an absolutely unacceptable state and needs fixing.

I don't care about which interface it is, if someting else fits
better, let's discuss that, but it has surely absolutely noting to do
with size/nr_blocks/nr_inodes.

Kay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
