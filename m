Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA30896
	for <linux-mm@kvack.org>; Wed, 22 Jul 1998 10:27:53 -0400
Date: Wed, 22 Jul 1998 11:36:38 +0100
Message-Id: <199807221036.LAA00829@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: More info: 2.1.108 page cache performance on low memory
In-Reply-To: <m1pvf3jeob.fsf@flinx.npwt.net>
References: <199807131653.RAA06838@dax.dcs.ed.ac.uk>
	<m190lxmxmv.fsf@flinx.npwt.net>
	<199807141730.SAA07239@dax.dcs.ed.ac.uk>
	<m14swgm0am.fsf@flinx.npwt.net>
	<87d8b370ge.fsf@atlas.CARNet.hr>
	<m1pvf3jeob.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: Zlatko.Calusic@CARNet.hr, "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 18 Jul 1998 11:40:20 -0500, ebiederm+eric@npwt.net (Eric
W. Biederman) said:

> Agreed.  We should look very carefully though to see if any aging
> solution increases fragmentation.  According to Stephen the current
> one does, and this may be a natural result of aging and not just a
> single implementation :(

No no no!  The current VM has two separate but related problems.  First
is that it keeps too much cache in low memory configurations, and that
appears to be much much better in 2.1.109 and 110.  Second is the
fragmentation issue, but that's a lot harder to address I'm afraid.  I
have a zoned allocator now working which does help enormously: it's the
first time my VM-test 2.1 configuration has _ever_ been able to run
successfully with 8k NFS.  However, the zoned allocation can use memory
less efficiently: the odd free pages in the paged zone cannot be used by
non-paged users and vice versa, so overall performance may suffer.
Right now I'm cleaning the code up for a release against 2.1.110 so
that we can start testing.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
