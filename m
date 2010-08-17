Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 641C26B01F0
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 04:25:06 -0400 (EDT)
Subject: Re: [RFC][PATCH] Per file dirty limit throttling
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <201008171039.23701.knikanth@suse.de>
References: <201008160949.51512.knikanth@suse.de>
	 <1281956742.1926.1217.camel@laptop>  <201008171039.23701.knikanth@suse.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 17 Aug 2010 10:24:35 +0200
Message-ID: <1282033475.1926.2093.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Bill Davidsen <davidsen@tmr.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-08-17 at 10:39 +0530, Nikanth Karthikesan wrote:
> Oh, nice.  Per-task limit is an elegant solution, which should help durin=
g=20
> most of the common cases.
>=20
> But I just wonder what happens, when
> 1. The dirtier is multiple co-operating processes
> 2. Some app like a shell script, that repeatedly calls dd with seek and s=
kip?=20
> People do this for data deduplication, sparse skipping etc..
> 3. The app dies and comes back again. Like a VM that is rebooted, and=20
> continues writing to a disk backed by a file on the host.
>=20
> Do you think, in those cases this might still be useful?=20

Those cases do indeed defeat the current per-task-limit, however I think
the solution to that is to limit the amount of writeback done by each
blocked process.

Jan Kara had some good ideas in that department.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
