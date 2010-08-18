Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6E1816B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 05:59:08 -0400 (EDT)
Subject: Re: [RFC][PATCH] Per file dirty limit throttling
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <201008181452.05047.knikanth@suse.de>
References: <201008160949.51512.knikanth@suse.de>
	 <201008171039.23701.knikanth@suse.de> <1282033475.1926.2093.camel@laptop>
	 <201008181452.05047.knikanth@suse.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 18 Aug 2010 11:58:56 +0200
Message-ID: <1282125536.1926.3675.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Bill Davidsen <davidsen@tmr.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-08-18 at 14:52 +0530, Nikanth Karthikesan wrote:
> On Tuesday 17 August 2010 13:54:35 Peter Zijlstra wrote:
> > On Tue, 2010-08-17 at 10:39 +0530, Nikanth Karthikesan wrote:
> > > Oh, nice.  Per-task limit is an elegant solution, which should help
> > > during most of the common cases.
> > >
> > > But I just wonder what happens, when
> > > 1. The dirtier is multiple co-operating processes
> > > 2. Some app like a shell script, that repeatedly calls dd with seek a=
nd
> > > skip? People do this for data deduplication, sparse skipping etc..
> > > 3. The app dies and comes back again. Like a VM that is rebooted, and
> > > continues writing to a disk backed by a file on the host.
> > >
> > > Do you think, in those cases this might still be useful?
> >=20
> > Those cases do indeed defeat the current per-task-limit, however I thin=
k
> > the solution to that is to limit the amount of writeback done by each
> > blocked process.
> >=20
>=20
> Blocked on what? Sorry, I do not understand.

balance_dirty_pages(), by limiting the work done there (or actually, the
amount of page writeback completions you wait for -- starting IO isn't
that expensive), you can also affect the time it takes, and therefore
influence the impact.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
