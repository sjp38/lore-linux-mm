Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 2C8976B005D
	for <linux-mm@kvack.org>; Wed, 30 May 2012 15:54:27 -0400 (EDT)
Received: by yhr47 with SMTP id 47so240164yhr.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 12:54:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1205301441350.31768@router.home>
References: <1338368529-21784-1-git-send-email-kosaki.motohiro@gmail.com>
 <CA+55aFzoVQ29C-AZYx=G62LErK+7HuTCpZhvovoyS0_KTGGZQg@mail.gmail.com>
 <alpine.DEB.2.00.1205301328550.31768@router.home> <20120530184638.GU27374@one.firstfloor.org>
 <alpine.DEB.2.00.1205301349230.31768@router.home> <20120530193234.GV27374@one.firstfloor.org>
 <alpine.DEB.2.00.1205301441350.31768@router.home>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Wed, 30 May 2012 15:54:06 -0400
Message-ID: <CAHGf_=ooVunBpSdBRCnO1uOoswqxcSy7Xf8xVcgEUGA2fXdcTA@mail.gmail.com>
Subject: Re: [PATCH 0/6] mempolicy memory corruption fixlet
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andi Kleen <andi@firstfloor.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, stable@vger.kernel.org, hughd@google.com, sivanich@sgi.com

On Wed, May 30, 2012 at 3:42 PM, Christoph Lameter <cl@linux.com> wrote:
> On Wed, 30 May 2012, Andi Kleen wrote:
>
>> On Wed, May 30, 2012 at 01:50:02PM -0500, Christoph Lameter wrote:
>> > On Wed, 30 May 2012, Andi Kleen wrote:
>> >
>> > > I always regretted that cpusets were no done with custom node lists.
>> > > That would have been much cleaner and also likely faster than what we have.
>> >
>> > Could shared memory policies ignore cpuset constraints?
>>
>> Only if noone uses cpusets as a "security" mechanism, just for a "soft policy"
>> Even with soft policy you could well break someone's setup.
>
> Well at least lets exempt shared memory from memory migration and memory
> policy updates. That seems to be causing many of these issues.

Yes, that's right direction, I think. Currently, shmem_set_policy() can't handle
nonlinear mapping. vma -> file offset transration is not so easy work
and I doubt
we should do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
