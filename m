Received: from ife.ee.ethz.ch (ife-fast.ee.ethz.ch [129.132.24.193])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA16520
	for <linux-mm@kvack.org>; Tue, 26 Jan 1999 16:24:36 -0500
Message-ID: <36AE3276.9BB1789F@ife.ee.ethz.ch>
Date: Tue, 26 Jan 1999 22:24:06 +0100
From: Thomas Sailer <sailer@ife.ee.ethz.ch>
MIME-Version: 1.0
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
References: <Pine.LNX.3.95.990126210417.374A-100000@localhost>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gerard Roudier <groudier@club-internet.fr>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Gerard Roudier wrote:

> What can we do, if some people that have such machines want to use
> IO controllers that are not able to DMA the whole physical space?

Does it matter for a soundcard that just needs its 64k buffer allocated
on driver open and then be happy for the rest of its life?

Fact is that soundcard design was broken since its inception and
I've given up hope that someone in that business sees some light 8-)

> Are you sure a soundcard is really required for systems that run
> with GBs of memory?

Have you seen a PC without one lately?
Allmost all Linux guys I know want to listen to MP3 files 8-)

Tom
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
