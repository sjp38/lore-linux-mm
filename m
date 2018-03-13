Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6DC936B005D
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 10:35:24 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id az5-v6so10293236plb.14
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 07:35:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l7-v6sor101996pls.108.2018.03.13.07.35.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Mar 2018 07:35:23 -0700 (PDT)
Date: Tue, 13 Mar 2018 23:35:20 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCHv2 2/2] zram: drop max_zpage_size and use
 zs_huge_class_size()
Message-ID: <20180313143520.GB741@tigerII.localdomain>
References: <20180306070639.7389-1-sergey.senozhatsky@gmail.com>
 <20180306070639.7389-3-sergey.senozhatsky@gmail.com>
 <20180313090249.GA240650@rodete-desktop-imager.corp.google.com>
 <20180313102437.GA5114@jagdpanzerIV>
 <20180313135815.GA96381@rodete-laptop-imager.corp.google.com>
 <20180313141813.GA741@tigerII.localdomain>
 <20180313142920.GA100978@rodete-laptop-imager.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180313142920.GA100978@rodete-laptop-imager.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

On (03/13/18 23:29), Minchan Kim wrote:
[..]
> > Can do, but the param will be unused. May be we can do something
> 
> Yub, param wouldn't be unused but it's the way of creating dependency
> intentionally. It could make code more robust/readable.
> 
> Please, let's pass zs_pool and returns always right huge size.

OK, no prob. Will send an updated version tomorrow.

	-ss
