Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA31184
	for <linux-mm@kvack.org>; Mon, 27 Jul 1998 15:44:44 -0400
Date: Mon, 27 Jul 1998 11:40:03 +0100
Message-Id: <199807271040.LAA00699@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: More info: 2.1.108 page cache performance on low memory
In-Reply-To: <19980723211222.37937@boole.suse.de>
References: <199807131653.RAA06838@dax.dcs.ed.ac.uk>
	<m190lxmxmv.fsf@flinx.npwt.net>
	<199807141730.SAA07239@dax.dcs.ed.ac.uk>
	<m14swgm0am.fsf@flinx.npwt.net>
	<87d8b370ge.fsf@atlas.CARNet.hr>
	<199807221033.LAA00826@dax.dcs.ed.ac.uk>
	<87hg08vnmt.fsf@atlas.CARNet.hr>
	<19980723211222.37937@boole.suse.de>
Sender: owner-linux-mm@kvack.org
To: "Dr. Werner Fink" <werner@suse.de>
Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi Werner,

On Thu, 23 Jul 1998 21:12:22 +0200, "Dr. Werner Fink" <werner@suse.de>
said:

> I've something similar ... cut&paste (no tabs) ... which would only do
> less graduated ageing on small systems.

> ----------------------------------------------------------------------------
> [patch follows]

Interesting, but the patch included just two copies of the diff to
swapctl.h and no definition of the new do_pgcache_max_age() function.
Could you post a complete patch, please?!

Thanks,
 Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
