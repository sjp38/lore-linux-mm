Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel:  it'snot just the code)
References: <20000607144102.F30951@redhat.com>
	<Pine.LNX.4.21.0006071103560.14304-100000@duckman.distro.conectiva>
	<20000607154620.O30951@redhat.com> <yttog5decvq.fsf@serpe.mitica>
	<393EAD84.A4BB6BD9@reiser.to> <20000607215436.F30951@redhat.com>
	<393EBEB5.AEEFF501@reiser.to>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Hans Reiser's message of "Wed, 07 Jun 2000 14:29:25 -0700"
Date: 07 Jun 2000 23:50:52 +0200
Message-ID: <yttpuptcg8z.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hans Reiser <hans@reiser.to>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@conectiva.com.br>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

>>>>> "hans" == Hans Reiser <hans@reiser.to> writes:

Hi

>> Every time we have tried to keep the caches completely separate, we
>> have ended up losing the ability to balance the various caches against
>> each other.  The major advantage of a common set of LRU lists is that
>> it gives us a basis for a balanced VM.
>> 
>> Cheers,
>> Stephen

hans> If I understand Juan correctly, they fixed this issue.  Aging 1/64th of the
hans> cache for every cache evenly at every round of trying to free pages should be an
hans> excellent fix.  It should do just fine at the task of handling a system with
hans> both ext3 and reiserfs running.

hans> Was this Juan's code that did this?  If so, kudos to him.

I am working in that also, but in the merging of all the caches
allways than possible. I.e. Rik and me done the defered swap patch, I
am finising the defered mmap page write and after that I will try the
defered shm code (I need to read the shm code first :()

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
