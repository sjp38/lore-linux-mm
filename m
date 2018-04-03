Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 21A626B0005
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 19:45:25 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id q12-v6so9600821plr.17
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 16:45:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j5si1105216pgq.406.2018.04.03.16.45.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 16:45:24 -0700 (PDT)
Date: Tue, 3 Apr 2018 16:45:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/migrate: properly preserve write attribute in
 special migrate entry
Message-Id: <20180403164522.657185a44e8ada1b741f0a9e@linux-foundation.org>
In-Reply-To: <20180403230336.GH5935@redhat.com>
References: <20180402023506.12180-1-jglisse@redhat.com>
	<20180403153046.88cae4ab18646e8e23a648ce@linux-foundation.org>
	<20180403230336.GH5935@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>

On Tue, 3 Apr 2018 19:03:36 -0400 Jerome Glisse <jglisse@redhat.com> wrote:

> > That sounds a bit serious.  Was a -stable backport considered?
> 
> Like discuss previously with Michal, for lack of upstream user yet
> (and PowerPC users of this code are not upstream either yet AFAIK).
> 
> Once i get HMM inside nouveau upstream, i will evaluate if people
> wants all fixes to be back ported to stable.
> 
> Finaly this one isn't too bad, it just burn CPU cycles by forcing
> CPU to take a second fault on write access ie double fault the same
> address. There is no corruption or incorrect states (it behave as
> a COWed page from a fork with a mapcount of 1).

OK, I updated the changelog with this info.

> Do you still want me to be more aggressive with stable backport ?
> I don't mind either way. I expect to get HMM nouveau upstream over
> next couple release cycle.

I guess that doing a single, better-organized cherrypick at a suitable
time in the future is a good approach.  You might want to discuss this
plan with Greg before committing too far.
