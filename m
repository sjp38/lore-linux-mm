Subject: Re: journaling & VM 
References: <Pine.LNX.4.21.0006061956360.7328-100000@duckman.distro.conectiva> <393DA31A.358AE46D@reiser.to> <20000607121243.F29432@redhat.com>
From: "John Fremlin" <vii@penguinpowered.com>
Date: 07 Jun 2000 17:35:13 +0100
In-Reply-To: "Stephen C. Tweedie"'s message of "Wed, 7 Jun 2000 12:12:43 +0100"
Message-ID: <m2r9a9a1q6.fsf_-_@boreas.southchinaseas>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> writes:
[...]
> > There are two issues to address:
> > 
> > 1) If a buffer needs to be flushed to disk, how do we let the FS flush
> > everything else that it is optimal to flush at the same time as that buffer. 
> > zam's allocate on flush code addresses that issue for reiserfs, and he has some
> > general hooks implemented also.  He is guessed to be two weeks away.
> 
> That's easy to deal with using address_space callbacks from shrink_mmap.
> shrink_mmap just calls into the filesystem to tell it that something
> needs to be done.  The filesystem can, in response, flush as much data
> as it wants to in addition to the page requested --- or can flush none
> at all if the page is pinned.  The address_space callbacks should be
> thought of as hints from the VM that the filesystem needs to do 
> something.  shrink_mmap will keep on trying until it finds something
> to free if nothing happens on the first call.
> 
I don't understand the idea behind this. (Clueless newbie alert.)

You are saying, that the MM system maintains a list of pages, then
when it wants to free some memory it goes down the list seeing which
subsystem owns each page, and asks it to free some memory. (Correct me
if I am wrong).
That is, each filesystem or whatever can basically implement its own
MM. If so, why not simply have a list of subsystems that own memory
with some sort of measure of how much space they're wasting, and ask
the ones with a lot to free some?

-- 

	http://altern.org/vii
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
