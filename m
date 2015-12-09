Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id BD6A66B025C
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 09:41:58 -0500 (EST)
Received: by wmec201 with SMTP id c201so76613515wme.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 06:41:58 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id h7si11744965wjy.46.2015.12.09.06.41.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 06:41:57 -0800 (PST)
Date: Wed, 9 Dec 2015 09:41:53 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: page_alloc: fix variable type in zonelist type
 iteration
Message-ID: <20151209144153.GA21713@cmpxchg.org>
References: <1449583412-22740-1-git-send-email-hannes@cmpxchg.org>
 <alpine.DEB.2.10.1512081356290.29940@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.10.1512081356290.29940@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Dec 08, 2015 at 01:56:42PM -0800, David Rientjes wrote:
> On Tue, 8 Dec 2015, Johannes Weiner wrote:
> 
> > /home/hannes/src/linux/linux/mm/page_alloc.c: In function a??build_zonelistsa??:
> > /home/hannes/src/linux/linux/mm/page_alloc.c:4171:16: warning: comparison between a??enum zone_typea?? and a??enum <anonymous>a?? [-Wenum-compare]
> >   for (i = 0; i < MAX_ZONELISTS; i++) {
> >                 ^
> > 
> > MAX_ZONELISTS has never been of enum zone_type, probably gcc only
> > recently started including -Wenum-compare in -Wall.
> > 
> > Make i a simple int.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> I think this is already handled by 
> http://marc.info/?l=linux-kernel&m=144901185732632.

Yup, it does. Thanks, David. Scratch this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
