Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5E39A6B0025
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 17:18:07 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id k22so7549768qtj.0
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 14:18:07 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id r9si1951107qte.54.2018.03.16.14.18.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 14:18:06 -0700 (PDT)
Date: Fri, 16 Mar 2018 17:18:02 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 02/14] mm/hmm: fix header file if/else/endif maze
Message-ID: <20180316211801.GB4861@redhat.com>
References: <20180316191414.3223-1-jglisse@redhat.com>
 <20180316191414.3223-3-jglisse@redhat.com>
 <20180316140959.b603888e2a9ba2e42e56ba1f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180316140959.b603888e2a9ba2e42e56ba1f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>

On Fri, Mar 16, 2018 at 02:09:59PM -0700, Andrew Morton wrote:
> On Fri, 16 Mar 2018 15:14:07 -0400 jglisse@redhat.com wrote:
> 
> > From: Jerome Glisse <jglisse@redhat.com>
> > 
> > The #if/#else/#endif for IS_ENABLED(CONFIG_HMM) were wrong.
> 
> "were wrong" is not a sufficient explanation of the problem, especially
> if we're requesting a -stable backport.  Please fully describe the
> effects of a bug when fixing it?

Build issue (compilation failure) if you have multiple includes of
hmm.h through different headers is the most obvious issue. So it
will be very obvious with any big driver that include the file in
different headers.

I can respin with that. Sorry again for not being more explanatory
it is always hard for me to figure what is not obvious to others.

Cheers,
Jerome
