Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2AF196B0006
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 18:50:38 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id h81-v6so9887623itb.0
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 15:50:38 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0010.hostedemail.com. [216.40.44.10])
        by mx.google.com with ESMTPS id m63-v6si88901ite.16.2018.03.26.15.50.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 15:50:37 -0700 (PDT)
Message-ID: <1522104633.12357.36.camel@perches.com>
Subject: Re: [PATCH] mm: Use octal not symbolic permissions
From: Joe Perches <joe@perches.com>
Date: Mon, 26 Mar 2018 15:50:33 -0700
In-Reply-To: <20180326154149.4045ec03645d6983de6f11b3@linux-foundation.org>
References: 
	<2e032ef111eebcd4c5952bae86763b541d373469.1522102887.git.joe@perches.com>
	 <20180326154149.4045ec03645d6983de6f11b3@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2018-03-26 at 15:41 -0700, Andrew Morton wrote:
> On Mon, 26 Mar 2018 15:22:32 -0700 Joe Perches <joe@perches.com> wrote:
> 
> > mm/*.c files use symbolic and octal styles for permissions.
> > 
> > Using octal and not symbolic permissions is preferred by many as more
> > readable.
> > 
> > https://lkml.org/lkml/2016/8/2/1945
> > 
> > Prefer the direct use of octal for permissions.
> 
> Thanks.  I'll park this until after -rc1 because the
> benefit-to-potential-for-whoopsies ratio is rather low.

No worries.  Whenever.

If you don't like the whitespace changes, or the
sources change so much the patch doesn't apply
cleanly, use the command line below when convenient.

$ ./scripts/checkpatch.pl -f --fix-inplace --types=symbolic_perms mm/*.c
