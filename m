Date: Tue, 6 Feb 2001 16:48:11 +0100
From: Christoph Hellwig <hch@ns.caldera.de>
Subject: Re: address_space: Theory of operation?
Message-ID: <20010206164811.A7938@caldera.de>
References: <20010206134821.Q849@nightmaster.csn.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20010206134821.Q849@nightmaster.csn.tu-chemnitz.de>; from ingo.oeser@informatik.tu-chemnitz.de on Tue, Feb 06, 2001 at 01:48:21PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: linux-fsdevel@vger.redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 06, 2001 at 01:48:21PM +0100, Ingo Oeser wrote:
> is there any description of what address_space is supposed to to?
> 
> What are the address_space_operations expected to handle?

My pagecache chapter in Tigran's lki explains a little about
address_spaces.  It's not yet updated to 2.4.{0,1} (though I have
the update ready, thanks for the reminder :)).

Look at: http://www.moses.uklinux.net/lki-4.html

	Christoph

-- 
Whip me.  Beat me.  Make me maintain AIX.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
