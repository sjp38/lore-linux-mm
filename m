Date: Thu, 1 Feb 2001 18:20:21 +0100
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: [PATCH] vma limited swapin readahead
Message-ID: <20010201182021.N1173@nightmaster.csn.tu-chemnitz.de>
References: <20010201143606.P11607@redhat.com> <Pine.LNX.4.21.0102011441380.1321-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0102011441380.1321-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Thu, Feb 01, 2001 at 02:45:04PM -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, David Gould <dg@suse.com>, "Eric W. Biederman" <ebiederm@xmission.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 01, 2001 at 02:45:04PM -0200, Rik van Riel wrote:
> One solution could be to put (most of) the swapin readahead
> pages on the inactive_dirty list, so pressure by readahead
> on the resident pages is smaller and the not used readahead
> pages are reclaimed faster.

Shouldn't they be on inactive_clean anyway? They are not mapped
(if I read Stephens comment correctly) and are clean (because we
just read them in).

So if we have to put it there explicitly, we have at least a
performance bug, don't we?

Or do I still not get the new linux mm design? ;-(

Totally clueless

Ingo Oeser

PS: Who CC'ed is also subscribed to linux-mm? Or do we all filter
   dupes via "formail -D"? ;-)
-- 
10.+11.03.2001 - 3. Chemnitzer LinuxTag <http://www.tu-chemnitz.de/linux/tag>
         <<<<<<<<<<<<       come and join the fun       >>>>>>>>>>>>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
