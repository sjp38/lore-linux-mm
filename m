Date: Wed, 7 Jun 2000 22:33:52 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel: it'snot just the code)
Message-ID: <20000607223352.J30951@redhat.com>
References: <20000607144102.F30951@redhat.com> <Pine.LNX.4.21.0006071103560.14304-100000@duckman.distro.conectiva> <20000607154620.O30951@redhat.com> <yttog5decvq.fsf@serpe.mitica> <393EAD84.A4BB6BD9@reiser.to> <20000607215436.F30951@redhat.com> <393EBEB5.AEEFF501@reiser.to>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <393EBEB5.AEEFF501@reiser.to>; from hans@reiser.to on Wed, Jun 07, 2000 at 02:29:25PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hans Reiser <hans@reiser.to>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Quintela Carreira Juan J." <quintela@fi.udc.es>, Rik van Riel <riel@conectiva.com.br>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 07, 2000 at 02:29:25PM -0700, Hans Reiser wrote:
> 
> If I understand Juan correctly, they fixed this issue.  Aging 1/64th of the
> cache for every cache evenly at every round of trying to free pages should be an
> excellent fix.  It should do just fine at the task of handling a system with
> both ext3 and reiserfs running.

That is _exactly_ what breaks the VM balance!  The net result of
an algorithm like that is that all caches are shrunk at the same
rate regardless of which ones are busy.  The "shrink everything
at once" principle is what used to cause large filesystem scans 
(such as find|grep over a large source tree) to swap all our
running processes out.

There _has_ to be a way to allow the relative ages of the different
pages to influence the reclamation of pages from different sources.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
