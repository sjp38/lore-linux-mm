Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 96995280340
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 16:26:54 -0400 (EDT)
Received: by pdbbh15 with SMTP id bh15so21328984pdb.1
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 13:26:54 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bf3si20358367pbc.29.2015.07.17.13.26.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 13:26:53 -0700 (PDT)
Date: Fri, 17 Jul 2015 13:26:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/9] mm: Provide new get_vaddr_frames() helper
Message-Id: <20150717132651.18aee9571f267200b9ad15f4@linux-foundation.org>
In-Reply-To: <55A8D7AC.3060709@xs4all.nl>
References: <1436799351-21975-1-git-send-email-jack@suse.com>
	<1436799351-21975-3-git-send-email-jack@suse.com>
	<55A8D7AC.3060709@xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hans Verkuil <hverkuil@xs4all.nl>
Cc: Jan Kara <jack@suse.com>, linux-media@vger.kernel.org, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, linux-samsung-soc@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

On Fri, 17 Jul 2015 12:23:40 +0200 Hans Verkuil <hverkuil@xs4all.nl> wrote:

> On 07/13/2015 04:55 PM, Jan Kara wrote:
> > From: Jan Kara <jack@suse.cz>
> > 
> > Provide new function get_vaddr_frames().  This function maps virtual
> > addresses from given start and fills given array with page frame numbers of
> > the corresponding pages. If given start belongs to a normal vma, the function
> > grabs reference to each of the pages to pin them in memory. If start
> > belongs to VM_IO | VM_PFNMAP vma, we don't touch page structures. Caller
> > must make sure pfns aren't reused for anything else while he is using
> > them.
> > 
> > This function is created for various drivers to simplify handling of
> > their buffers.
> > 
> > Acked-by: Mel Gorman <mgorman@suse.de>
> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> > Signed-off-by: Jan Kara <jack@suse.cz>
> 
> I'd like to see an Acked-by from Andrew or mm-maintainers before I merge this.

I think I already acked this but it got lost.

Acked-by: Andrew Morton <akpm@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
