Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 720706B01B2
	for <linux-mm@kvack.org>; Tue, 25 May 2010 02:55:31 -0400 (EDT)
Received: by fxm11 with SMTP id 11so2418055fxm.14
        for <linux-mm@kvack.org>; Mon, 24 May 2010 23:55:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100525020629.GA5087@laptop>
References: <20100521211452.659982351@quilx.com>
	<20100524070309.GU2516@laptop>
	<alpine.DEB.2.00.1005240852580.5045@router.home>
	<20100525020629.GA5087@laptop>
Date: Tue, 25 May 2010 09:55:28 +0300
Message-ID: <AANLkTik2O-_Fbh-dq0sSLFJyLU7PZi4DHm85lCo4sugS@mail.gmail.com>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <cl@linux-foundation.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 25, 2010 at 5:06 AM, Nick Piggin <npiggin@suse.de> wrote:
>> If can find criteria that are universally agreed upon then yes but that is
>> doubtful.
>
> I think we can agree that perfect is the enemy of good, and that no
> allocator will do the perfect thing for everybody. I think we have to
> come up with a way to a single allocator.

Yes. The interesting most interesting bit about SLEB for me is the
freelist handling as bitmaps, not necessarily the "queuing" part. If
the latter also helps some workloads, it's a bonus for sure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
