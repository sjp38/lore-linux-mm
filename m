Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA31306
	for <linux-mm@kvack.org>; Mon, 27 Jul 1998 15:48:37 -0400
Date: Mon, 27 Jul 1998 11:57:39 +0100
Message-Id: <199807271057.LAA00708@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: More info: 2.1.108 page cache performance on low memory
In-Reply-To: <87af60bbvo.fsf@atlas.CARNet.hr>
References: <199807131653.RAA06838@dax.dcs.ed.ac.uk>
	<m190lxmxmv.fsf@flinx.npwt.net>
	<199807141730.SAA07239@dax.dcs.ed.ac.uk>
	<m14swgm0am.fsf@flinx.npwt.net>
	<87d8b370ge.fsf@atlas.CARNet.hr>
	<m1pvf3jeob.fsf@flinx.npwt.net>
	<87hg0c6fz3.fsf@atlas.CARNet.hr>
	<199807221040.LAA00832@dax.dcs.ed.ac.uk>
	<87iukovq42.fsf@atlas.CARNet.hr>
	<199807231222.NAA04748@dax.dcs.ed.ac.uk>
	<87zpe0u0dg.fsf@atlas.CARNet.hr>
	<199807231718.SAA13683@dax.dcs.ed.ac.uk>
	<87af60bbvo.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Zlatko.Calusic@CARNet.hr
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@npwt.net>, werner@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> In the mean time, I applied the same benchmark, I was already doing,
> to kernel with Werner's lowmem patch applied, and results are
> interesting. Performance is very similar to that with my change, but
> there are some differences. With Werner's patch, kernel behaviour is
> yet slightly less aggressive:

OK, time to look at a bigger set of benchmarks for this.  If it helps
this case, it needs to be considered for 2.2.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
