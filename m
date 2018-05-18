Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2A5586B05F2
	for <linux-mm@kvack.org>; Fri, 18 May 2018 12:33:27 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id x2-v6so5365086plv.0
        for <linux-mm@kvack.org>; Fri, 18 May 2018 09:33:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l36-v6sor4238619plg.100.2018.05.18.09.33.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 May 2018 09:33:25 -0700 (PDT)
Subject: Re: [PATCH 00/10] Misc block layer patches for bcachefs
References: <20180509013358.16399-1-kent.overstreet@gmail.com>
 <b3970608-95dd-3d4f-140c-3d7cbd12cf8d@kernel.dk>
 <20180518162314.GC25227@infradead.org>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <8fcb7b62-d3ac-54b6-3cb7-45864cafe2b1@kernel.dk>
Date: Fri, 18 May 2018 10:33:22 -0600
MIME-Version: 1.0
In-Reply-To: <20180518162314.GC25227@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Kent Overstreet <kent.overstreet@gmail.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On 5/18/18 10:23 AM, Christoph Hellwig wrote:
> On Fri, May 11, 2018 at 03:13:38PM -0600, Jens Axboe wrote:
>> Looked over the series, and looks like both good cleanups and optimizations.
>> If we can get the mempool patch sorted, I can apply this for 4.18.
> 
> FYI, I agree on the actual cleanups and optimization, but we really
> shouldn't add new functions or even just exports without the code
> using them.  I think it is enough if we can collect ACKs on them, but
> there is no point in using them.  Especially as I'd really like to see
> the users for some of them first.

I certainly agree on that in general, but at the same time it makes the
expected submission of bcachefs not having to carry a number of
(essentially) unrelated patches. I'm assuming the likelihood of bcachefs
being submitted soonish is high, hence we won't have exports that don't
have in-kernel users in the longer term.

-- 
Jens Axboe
