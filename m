Date: Thu, 1 Feb 2001 17:27:02 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] vma limited swapin readahead
Message-ID: <20010201172702.X11607@redhat.com>
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

Hi,

On Thu, Feb 01, 2001 at 02:45:04PM -0200, Rik van Riel wrote:
> On Thu, 1 Feb 2001, Stephen C. Tweedie wrote:
> 
> But only when the extra pages we're reading in don't
> displace useful data from memory, making us fault in
> those other pages ... causing us to go to the disk
> again and do more readahead, which could potentially
> displace even more pages, etc...

Remember, it's a balance.  You can displace a few useful pages and
still win overall because the cost _per page_ goes way down due to
better disk IO utilisation.

> One solution could be to put (most of) the swapin readahead
> pages on the inactive_dirty list, so pressure by readahead
> on the resident pages is smaller and the not used readahead
> pages are reclaimed faster.

Yep, that would make much sense.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
