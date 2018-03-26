Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 55B4A6B0006
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 18:41:52 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id bi1-v6so5584979plb.11
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 15:41:52 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a61-v6si15670442pla.271.2018.03.26.15.41.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 15:41:51 -0700 (PDT)
Date: Mon, 26 Mar 2018 15:41:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Use octal not symbolic permissions
Message-Id: <20180326154149.4045ec03645d6983de6f11b3@linux-foundation.org>
In-Reply-To: <2e032ef111eebcd4c5952bae86763b541d373469.1522102887.git.joe@perches.com>
References: <2e032ef111eebcd4c5952bae86763b541d373469.1522102887.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 26 Mar 2018 15:22:32 -0700 Joe Perches <joe@perches.com> wrote:

> mm/*.c files use symbolic and octal styles for permissions.
> 
> Using octal and not symbolic permissions is preferred by many as more
> readable.
> 
> https://lkml.org/lkml/2016/8/2/1945
> 
> Prefer the direct use of octal for permissions.

Thanks.  I'll park this until after -rc1 because the
benefit-to-potential-for-whoopsies ratio is rather low.
