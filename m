Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6EBD06B0292
	for <linux-mm@kvack.org>; Fri, 26 May 2017 00:15:52 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id m5so253381581pfc.1
        for <linux-mm@kvack.org>; Thu, 25 May 2017 21:15:52 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id f21si7689578plj.322.2017.05.25.21.15.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 21:15:51 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id n23so43212534pfb.3
        for <linux-mm@kvack.org>; Thu, 25 May 2017 21:15:51 -0700 (PDT)
Date: Thu, 25 May 2017 21:15:48 -0700
From: Nick Desaulniers <nick.desaulniers@gmail.com>
Subject: Re: [PATCH] mm/zsmalloc: fix -Wunneeded-internal-declaration warning
Message-ID: <20170526041548.vq7vwogsk266aivp@lostoracle.net>
References: <20170524053859.29059-1-nick.desaulniers@gmail.com>
 <20170524081617.GA3311@jagdpanzerIV.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170524081617.GA3311@jagdpanzerIV.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: md@google.com, mka@chromium.org, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, May 24, 2017 at 05:16:18PM +0900, Sergey Senozhatsky wrote:
> On (05/23/17 22:38), Nick Desaulniers wrote:
> > Fixes the following warning, found with Clang:
> well, no objections from my side. MM seems to be getting more and
> more `__maybe_unused' annotations because of clang.

Indeed, but does find bugs when this warning pops up unexpected (unlike
in this particular instance). See:

https://patchwork.kernel.org/patch/9738897/
https://www.spinics.net/lists/intel-gfx/msg128737.html

TL;DR
>>> You have actually uncovered a bug here where the call is not
>>> supposed to be optional in the first place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
