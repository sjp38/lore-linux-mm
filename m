Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CE8D06B0096
	for <linux-mm@kvack.org>; Sat, 30 May 2009 03:12:28 -0400 (EDT)
Received: by bwz21 with SMTP id 21so8754647bwz.38
        for <linux-mm@kvack.org>; Sat, 30 May 2009 00:12:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090529155859.2cf20823.akpm@linux-foundation.org>
References: <20090520183045.GB10547@oblivion.subreption.com>
	 <1242852158.6582.231.camel@laptop>
	 <20090520212413.GF10756@oblivion.subreption.com>
	 <20090529155859.2cf20823.akpm@linux-foundation.org>
Date: Sat, 30 May 2009 10:12:38 +0300
Message-ID: <84144f020905300012h6ca92605ve8fdcbaba39ac054@mail.gmail.com>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Larry H." <research@subreption.com>, peterz@infradead.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, linux-mm@kvack.org, mingo@redhat.com, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

Hi Andrew,

On Sat, May 30, 2009 at 1:58 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> =A0But how to do that? =A0Particular callsites don't get to alter
> =A0kfree()'s behaviour. =A0So they'd need to use a new kfree_sensitive().
> =A0Which is just syntactic sugar around the code whihc we presently
> =A0implement.

Unless I am missing something here, we already have kfree_sensitive(),
we just call it kzfree().

                                 Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
