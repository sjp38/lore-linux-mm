Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 961B66B0032
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 17:40:18 -0500 (EST)
Received: by mail-qg0-f45.google.com with SMTP id h3so85580qgf.4
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 14:40:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 22si32302932qhx.4.2015.02.24.14.40.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 14:40:17 -0800 (PST)
Date: Tue, 24 Feb 2015 17:08:44 -0500
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH] mm: readahead: get back a sensible upper limit
Message-ID: <20150224220843.GL19014@t510.redhat.com>
References: <9cc2b63100622f5fd17fa5e4adc59233a2b41877.1424779443.git.aquini@redhat.com>
 <CA+55aFz4D9fS1xt7fg0R9Bnngg+_TbNs3fSAaFwoV7eTeLfP5Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFz4D9fS1xt7fg0R9Bnngg+_TbNs3fSAaFwoV7eTeLfP5Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, loberman@redhat.com, Larry Woodman <lwoodman@redhat.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>

On Tue, Feb 24, 2015 at 01:56:25PM -0800, Linus Torvalds wrote:
> On Tue, Feb 24, 2015 at 4:58 AM, Rafael Aquini <aquini@redhat.com> wrote:
> >
> > This patch brings back the old behavior of max_sane_readahead()
> 
> Yeah no.
> 
> There was a reason that code was killed. No way in hell are we
> bringing back the insanities with node memory etc.
>

Would you consider bringing it back, but instead of node memory state,
utilizing global memory state instead?
 
> Also, we have never actually heard of anything sane that actualyl
> depended on this. Last time this came up it was a made-up benchmark,
> not an actual real load that cared.
> 
> Who can possibly care about this in real life?
> 
People filing bugs complaining their applications that memory map files
are getting hurt by it.

-- Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
