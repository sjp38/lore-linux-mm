Date: Fri, 20 Feb 1998 00:41:19 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: How to read-protect a vm_area?
In-Reply-To: <199802192321.XAA06580@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.95.980220001508.8311A-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: Rik van Riel <H.H.vanRiel@fys.ruu.nl>, Linus Torvalds <torvalds@transmeta.com>, Itai Nahshon <nahshon@actcom.co.il>, Alan Cox <alan@lxorguk.ukuu.org.uk>, paubert@iram.es, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Feb 1998, Stephen C. Tweedie wrote:
...
> Please do let me know if you want to start hacking around with this
> code --- we probably want to coordinate with some of the other VM
> things happening at the moment (in particular, things like Ingo's swap
> prediction and the dirty page caching suggestions).
...

Just to let people know, as a successor to my pte-list/swapping patch from
the 2.1.48/66 days (which made running X on my nfs-root'd [34]86
possible/reliable), I'm currently mostly done a patch that does Mach-style
page replacement (active/inactive/free) as an alternative to kswapd.  I'm
also hoping to work on adding a per-cpu free page cache to get_free_page
later this month when my PPros arrive (grumble).

As Rik mentioned, please feel free to make use of linux-mm@kvack.org for
discussion purposes. (echo subscribe | mail majordomo@kvack.org)  It's
been quite, but then it's Febuary.

About the dirty page caching suggestions:  Eric W. Biederman
<ebiederm+eric@npwt.net> wrote patches to support that against 2.1.78, but
last time the issue was brought up, things became messy as NFS needs
dentries now, yet we'll only ever have inodes in struct page.  Now that
the dentry list is back in the inode, perhaps a patch to revert
read/writepage to non-dentry arguments could be accepted?  (NFS could get
its dentry from the i_dentry list.)

Linus: how far off are you hoping for 2.2?  It seems like there are
icebreakers out on the first code freeze...  Or maybe that just how things
work ;-)

		-ben
