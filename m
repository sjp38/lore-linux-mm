Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel: it'snot just the code)
References: <393E8AEF.7A782FE4@reiser.to>
	<Pine.LNX.4.21.0006071459040.14304-100000@duckman.distro.conectiva>
	<20000607205819.E30951@redhat.com>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: "Stephen C. Tweedie"'s message of "Wed, 7 Jun 2000 20:58:19 +0100"
Date: 07 Jun 2000 22:56:17 +0200
Message-ID: <ytt1z29dxce.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Hans Reiser <hans@reiser.to>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

>>>>> "sct" == Stephen C Tweedie <sct@redhat.com> writes:

Hi

>> I'd like to be able to keep stuff simple in the shrink_mmap
>> "equivalent" I'm working on. Something like:
>> 
>> if (PageDirty(page) && page->mapping && page->mapping->flush)
>> maxlaunder -= page->mapping->flush();

sct> That looks ideal.

But this is supposed to flush that _page_, at least in the normal
case.

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
