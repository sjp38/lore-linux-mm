Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BFFF56B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 11:02:00 -0500 (EST)
Subject: Re: [PATCH] writeback: prevent bandwidth calculation overflow
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20101118154408.GA18582@localhost>
References: <20101118065725.GB8458@localhost> <4CE537BE.6090103@redhat.com>
	 <20101118154408.GA18582@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 18 Nov 2010 17:02:01 +0100
Message-ID: <1290096121.2109.1525.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Li, Shaohua" <shaohua.li@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-11-18 at 23:44 +0800, Wu Fengguang wrote:
> +               pause =3D HZ * pages_dirtied / (bw + 1);

Shouldn't that be using something like div64_u64 ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
