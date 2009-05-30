Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 27B916B00A4
	for <linux-mm@kvack.org>; Sat, 30 May 2009 03:39:10 -0400 (EDT)
Received: by fxm12 with SMTP id 12so8994693fxm.38
        for <linux-mm@kvack.org>; Sat, 30 May 2009 00:39:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090530073528.GK29711@oblivion.subreption.com>
References: <20090520183045.GB10547@oblivion.subreption.com>
	 <1242852158.6582.231.camel@laptop>
	 <20090520212413.GF10756@oblivion.subreption.com>
	 <20090529155859.2cf20823.akpm@linux-foundation.org>
	 <84144f020905300012h6ca92605ve8fdcbaba39ac054@mail.gmail.com>
	 <20090530073528.GK29711@oblivion.subreption.com>
Date: Sat, 30 May 2009 10:39:44 +0300
Message-ID: <84144f020905300039t2eb80b86tea044a636161c9b9@mail.gmail.com>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, peterz@infradead.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, linux-mm@kvack.org, mingo@redhat.com, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

On Sat, May 30, 2009 at 1:58 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> > > ?But how to do that? ?Particular callsites don't get to alter
> > > ?kfree()'s behaviour. ?So they'd need to use a new kfree_sensitive().
> > > ?Which is just syntactic sugar around the code whihc we presently
> > > ?implement.

On 10:12 Sat 30 May, Pekka Enberg wrote:
>> Unless I am missing something here, we already have kfree_sensitive(),
>> we just call it kzfree().

On Sat, May 30, 2009 at 10:35 AM, Larry H. <research@subreption.com> wrote:
> You should test that. The results might be surprising, though.

So what's the problem with it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
