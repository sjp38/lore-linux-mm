Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 574E86B01F3
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 06:39:57 -0400 (EDT)
Subject: Re: [PATCH] writeback: remove the internal 5% low bound on
 dirty_ratio
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100827103603.GB6237@localhost>
References: <20100827103603.GB6237@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 27 Aug 2010 12:39:39 +0200
Message-ID: <1282905579.1975.2141.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Neil Brown <neilb@suse.de>, Con Kolivas <kernel@kolivas.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "david@fromorbit.com" <david@fromorbit.com>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-08-27 at 18:36 +0800, Wu Fengguang wrote:
> The dirty_ratio was siliently limited in global_dirty_limits() to >=3D 5%=
