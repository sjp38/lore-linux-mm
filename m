Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 1FE006B0062
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 17:25:17 -0400 (EDT)
Date: Fri, 8 Jun 2012 16:25:14 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [Resend PATCH v2] mm: Fix slab->page _count corruption.
In-Reply-To: <20120608133226.cd9a1167.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1206081622370.4213@router.home>
References: <1338405610-1788-1-git-send-email-pshelar@nicira.com> <20120608131045.90708bda.akpm@linux-foundation.org> <alpine.DEB.2.00.1206081514130.4213@router.home> <20120608133226.cd9a1167.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pravin B Shelar <pshelar@nicira.com>, penberg@kernel.org, aarcange@redhat.com, linux-mm@kvack.org, abhide@nicira.com

On Fri, 8 Jun 2012, Andrew Morton wrote:

> > So far I thouight that the field names are pretty clear on their own.
>
> Kidding?  I had to grep the tree just to find out which subsystem owns
> these.

Reading the comments a couple of lines up would have helped as well.

But anyways we are already adding more comments in the upcoming patchsets
for the next merge.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
