Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 235B76B0261
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 15:41:14 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 5so1587235777pgi.2
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 12:41:14 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r88si80622341pfg.173.2017.01.06.12.41.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 12:41:13 -0800 (PST)
Date: Fri, 6 Jan 2017 12:42:33 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Fix SLAB freelist randomization duplicate entries
Message-Id: <20170106124233.189364f79056513b62ebc026@linux-foundation.org>
In-Reply-To: <CAJcbSZFD=YLqXPKSTLUNFpOnTuYGMM7=YNrzxJ1C2L2MxR-8hw@mail.gmail.com>
References: <20170103181908.143178-1-thgarnie@google.com>
	<20170105163527.d37a29d6e7b3bfdafd7472d2@linux-foundation.org>
	<CAJcbSZFD=YLqXPKSTLUNFpOnTuYGMM7=YNrzxJ1C2L2MxR-8hw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, John Sperbeck <jsperbeck@google.com>

On Fri, 6 Jan 2017 09:58:48 -0800 Thomas Garnier <thgarnie@google.com> wrote:

> On Thu, Jan 5, 2017 at 4:35 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Tue,  3 Jan 2017 10:19:08 -0800 Thomas Garnier <thgarnie@google.com> wrote:
> >
> >> This patch fixes a bug in the freelist randomization code. When a high
> >> random number is used, the freelist will contain duplicate entries. It
> >> will result in different allocations sharing the same chunk.
> >
> > Important: what are the user-visible runtime effects of the bug?
> 
> It will result in odd behaviours and crashes. It should be uncommon
> but it depends on the machines. We saw it happening more often on some
> machines (every few hours of running tests).

So should the fix be backported into -stable kernels?

> >
> >> Fixes: c7ce4f60ac19 ("mm: SLAB freelist randomization")
> >> Signed-off-by: John Sperbeck <jsperbeck@google.com>
> >> Reviewed-by: Thomas Garnier <thgarnie@google.com>
> >
> > This should have been signed off by yourself.
> >
> > I'm guessing that the author was in fact John?  If so, you should
> > indicate this by putting his From: line at the start of the changelog.
> > Otherwise, authorship will default to the sender (ie, yourself).
> >
> 
> Sorry, I though the sign-off was enough. Do you want me to send a v2?

I have the patch as

From: John Sperbeck <jsperbeck@google.com>
Signed-off-by: John Sperbeck <jsperbeck@google.com>
Signed-off-by: Thomas Garnier <thgarnie@google.com>

Is that correct?  Is John the primary author?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
