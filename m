Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 031C46B0005
	for <linux-mm@kvack.org>; Wed,  4 May 2016 21:19:30 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id s184so15043624vkb.0
        for <linux-mm@kvack.org>; Wed, 04 May 2016 18:19:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 6si4469066qkp.25.2016.05.04.18.19.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 18:19:29 -0700 (PDT)
Date: Wed, 4 May 2016 19:19:27 -0600
From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [BUG] vfio device assignment regression with THP ref counting
 redesign
Message-ID: <20160504191927.095cdd90@t450s.home>
In-Reply-To: <20160502180307.GB12310@redhat.com>
References: <20160428181726.GA2847@node.shutemov.name>
	<20160428125808.29ad59e5@t450s.home>
	<20160428232127.GL11700@redhat.com>
	<20160429005106.GB2847@node.shutemov.name>
	<20160428204542.5f2053f7@ul30vt.home>
	<20160429070611.GA4990@node.shutemov.name>
	<20160429163444.GM11700@redhat.com>
	<20160502104119.GA23305@node.shutemov.name>
	<20160502152307.GA12310@redhat.com>
	<20160502160042.GC24419@node.shutemov.name>
	<20160502180307.GB12310@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, 2 May 2016 20:03:07 +0200
Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Mon, May 02, 2016 at 07:00:42PM +0300, Kirill A. Shutemov wrote:
> > Agreed. I just didn't see the two-refcounts solution.  
> 
> If you didn't do it already or if you're busy with something else,
> I can change the patch to the two refcount solution, which should
> restore the old semantics without breaking rmap.

I didn't see any follow-up beyond this nor patches on lkml.  Do we have
something we feel confident for posting to v4.6 with a stable backport
to v4.5?  Thanks,

Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
