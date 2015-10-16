Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3103982F64
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 18:35:46 -0400 (EDT)
Received: by pabws5 with SMTP id ws5so1910791pab.1
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 15:35:45 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ct3si32297151pad.103.2015.10.16.15.35.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Oct 2015 15:35:45 -0700 (PDT)
Date: Fri, 16 Oct 2015 15:35:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH 0/8] introduce slabinfo extended mode
Message-Id: <20151016153544.2d70713d6a0f2afd5744fa00@linux-foundation.org>
In-Reply-To: <1444907673-8863-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1444907673-8863-1-git-send-email-sergey.senozhatsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On Thu, 15 Oct 2015 20:14:25 +0900 Sergey Senozhatsky <sergey.senozhatsky@gmail.com> wrote:

> Add 'extended' slabinfo mode that provides additional information:
>  -- totals summary
>  -- slabs sorted by size
>  -- slabs sorted by loss (waste)
> 
> The patches also introduces several new slabinfo options to limit the
> number of slabs reported, sort slabs by loss (waste); and some fixes.

hm, why the "RFC"?  These patches look more mature than most of the
stuff I get ;)

You should have cc'ed linux-mm on these patches: nobody will have
noticed them.

slabinfo is documented a bit in Documentation/vm/slub.txt.  Please
review that file for accuracy and completeness.  It should at least
draw readers' attention to the new tools/vm/slabinfo-gnuplot.sh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
