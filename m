Message-ID: <393EAD84.A4BB6BD9@reiser.to>
Date: Wed, 07 Jun 2000 13:16:04 -0700
From: Hans Reiser <hans@reiser.to>
MIME-Version: 1.0
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel:
 it'snot just the code)
References: <20000607144102.F30951@redhat.com>
		<Pine.LNX.4.21.0006071103560.14304-100000@duckman.distro.conectiva>
		<20000607154620.O30951@redhat.com> <yttog5decvq.fsf@serpe.mitica>
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Quintela Carreira Juan J." <quintela@fi.udc.es>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@conectiva.com.br>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

"Quintela Carreira Juan J." wrote:

> 
> If you need pages in the LRU cache only for getting notifications,
> then change the system to send notifications each time that we are
> short of memory.

I think the right thing is for the filesystems to use the LRU code as templates
from which they may vary or not from in implementing their subcaches with their
own lists.  I say this for intuitive not concrete reasons.  In other words, I
agree with Juan.

Hans
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
