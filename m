Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 4F3746B0069
	for <linux-mm@kvack.org>; Wed, 30 May 2012 16:16:49 -0400 (EDT)
Received: by ghbf11 with SMTP id f11so286976ghb.8
        for <linux-mm@kvack.org>; Wed, 30 May 2012 13:16:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120530201042.GY27374@one.firstfloor.org>
References: <1338368529-21784-1-git-send-email-kosaki.motohiro@gmail.com>
 <CA+55aFzoVQ29C-AZYx=G62LErK+7HuTCpZhvovoyS0_KTGGZQg@mail.gmail.com>
 <alpine.DEB.2.00.1205301328550.31768@router.home> <20120530184638.GU27374@one.firstfloor.org>
 <alpine.DEB.2.00.1205301349230.31768@router.home> <20120530193234.GV27374@one.firstfloor.org>
 <alpine.DEB.2.00.1205301441350.31768@router.home> <CAHGf_=ooVunBpSdBRCnO1uOoswqxcSy7Xf8xVcgEUGA2fXdcTA@mail.gmail.com>
 <20120530201042.GY27374@one.firstfloor.org>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Wed, 30 May 2012 16:16:26 -0400
Message-ID: <CAHGf_=r_ZMKNx+VriO6822otF=U_huj7uxoc5GM-2DEVryKxNQ@mail.gmail.com>
Subject: Re: [PATCH 0/6] mempolicy memory corruption fixlet
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, stable@vger.kernel.org, hughd@google.com, sivanich@sgi.com

On Wed, May 30, 2012 at 4:10 PM, Andi Kleen <andi@firstfloor.org> wrote:
>> Yes, that's right direction, I think. Currently, shmem_set_policy() can't handle
>> nonlinear mapping.
>
> I've been mulling for some time to just remove non linear mappings.
> AFAIK they were only useful on 32bit and are obsolete and could be
> emulated with VMAs instead.

I agree. It is only userful on 32bit and current enterprise users don't use
32bit anymore. So, I don't think emulated by vmas cause user visible issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
