Date: Thu, 14 Sep 2000 14:49:11 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH *] VM patch for 2.4.0-test8
In-Reply-To: <Pine.LNX.4.21.0009141351510.10822-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0009141446570.1354-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

On Thu, 14 Sep 2000, Rik van Riel wrote:
> On Wed, 13 Sep 2000, David S. Miller wrote:
> 
> > In page_launder() about halfway down there is this sequence of tests
> > on LRU pages:
> > 
> > } else if (page_count(page) > 1) {
> > } else /* page->mapping && page_count(page) == 1 */ {
> 
> Indeed, you're right. This bug certainly explains some
> of the performance things I've seen in the stress test
> last night...

A new patch with Davem's bugfix has been uploaded and
performance seems to be quite a bit better now...

	http://www.surriel.com/patches/

Unless somebody else manages to find a bug in this patch,
this will be the last patch at this feature level and the
next patch will contain a new feature. The new feature in
question will be either the out of memory killer, or Ben
LaHaise's readahead-on-VMA-level code.

(probably the OOM killer since that is a stability-related
thing and the other is "just" a performance tweak)

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
