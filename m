Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B07B56B0089
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 05:43:16 -0500 (EST)
Subject: Re: [PATCH 3/3] mlock: avoid dirtying pages and triggering writeback
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
From: Theodore Tso <tytso@MIT.EDU>
In-Reply-To: <20101118054629.GA3339@amd>
Date: Thu, 18 Nov 2010 05:43:06 -0500
Content-Transfer-Encoding: quoted-printable
Message-Id: <2ADBEB7E-0EC8-4536-B556-0453A8E1D5FA@mit.edu>
References: <1289996638-21439-1-git-send-email-walken@google.com> <1289996638-21439-4-git-send-email-walken@google.com> <20101117125756.GA5576@amd> <1290007734.2109.941.camel@laptop> <20101118054629.GA3339@amd>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Theodore Tso <tytso@google.com>, Michael Rubin <mrubin@google.com>, Suleiman Souhlal <suleiman@google.com>
List-ID: <linux-mm.kvack.org>


On Nov 18, 2010, at 12:46 AM, Nick Piggin wrote:

> The right way to fix this would not be to introduce the new regression
> but either/both: a specific syscall to mlock-for-read which does not =
do
> any reservations, fix filesystem hook to allow reservation without
> implying dirtying. A simple flag to page_mkwrite will be enough (plus
> the logic to call it from VM).

Why is it at all important that mlock() force block allocation for =
sparse blocks?    It's  not at all specified in the mlock() API =
definition that it does that.

Are there really programs that assume that mlock() =3D=3D fallocate()?!?

-- Ted


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
