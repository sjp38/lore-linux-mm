Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5C0FB6B006A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 00:14:16 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id o964EEnE002239
	for <linux-mm@kvack.org>; Tue, 5 Oct 2010 21:14:14 -0700
Received: from iwn39 (iwn39.prod.google.com [10.241.68.103])
	by hpaq5.eem.corp.google.com with ESMTP id o964Cop3027712
	for <linux-mm@kvack.org>; Tue, 5 Oct 2010 21:14:13 -0700
Received: by iwn39 with SMTP id 39so12883683iwn.40
        for <linux-mm@kvack.org>; Tue, 05 Oct 2010 21:14:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4CABF4F3.7050002@zytor.com>
References: <1286265215-9025-1-git-send-email-walken@google.com>
	<1286265215-9025-4-git-send-email-walken@google.com>
	<4CABF4F3.7050002@zytor.com>
Date: Tue, 5 Oct 2010 21:14:12 -0700
Message-ID: <AANLkTi=+0i13JF552P7dF_JD+S10Lt8=+KySHdtg-Uex@mail.gmail.com>
Subject: Re: [PATCH 3/3] access_error API cleanup
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Ying Han <yinghan@google.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 5, 2010 at 9:02 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> I was going to put it into the x86 tree, but being part of a larger
> series it gets messy.

Yes. It's easy enough to reorder the patches, if we care about this
one making it into 2.6.36 ahead of the rest, but it does not seem like
a huge payoff either.

I figure barring any surprises, the series is likely to merge from -mm
tree to mainline in time for 2.6.37 ?

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
