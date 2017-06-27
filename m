Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6CDB16B02F4
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 03:11:08 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 12so3634579wmn.1
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 00:11:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j14si1865772wmd.133.2017.06.27.00.11.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 00:11:07 -0700 (PDT)
Date: Tue, 27 Jun 2017 09:11:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: OOM kills with lots of free swap
Message-ID: <20170627071104.GB28078@dhcp22.suse.cz>
References: <CAA25o9T1WmkWJn1LA-vS=W_Qu8pBw3rfMtTreLNu8fLuZjTDsw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA25o9T1WmkWJn1LA-vS=W_Qu8pBw3rfMtTreLNu8fLuZjTDsw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>

On Fri 23-06-17 16:29:39, Luigi Semenzato wrote:
> It is fairly easy to trigger OOM-kills with almost empty swap, by
> running several fast-allocating processes in parallel.  I can
> reproduce this on many 3.x kernels (I think I tried also on 4.4 but am
> not sure).  I am hoping this is a known problem.

The oom detection code has been reworked considerably in 4.7 so I would
like to see whether your problem is still presenet with more up-to-date
kernels. Also an OOM report is really necessary to get any clue what
might have been going on.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
