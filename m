Subject: Re: broken VM in 2.4.10-pre9
References: <Pine.LNX.4.33L.0109161330000.9536-100000@imladris.rielhome.conectiva>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 17 Sep 2001 02:06:46 -0600
In-Reply-To: <Pine.LNX.4.33L.0109161330000.9536-100000@imladris.rielhome.conectiva>
Message-ID: <m1elp6s0kp.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> On 16 Sep 2001, Michael Rothwell wrote:
> 
> > Is there a way to tell the VM to prune its cache? Or a way to limit
> > the amount of cache it uses?
> 
> Not yet, I'll make a quick hack for this when I get back next
> week. It's pretty obvious now that the 2.4 kernel cannot get
> enough information to select the right pages to evict from
> memory.

Hmm.  Perhaps or perhaps it is using the information poorly.
There is an alternative approach to have better aging information.

An address_space can be allocated per mm_struct.    And all of the
anonymous pages can be allocated to that address_space.  The
address_space can then have an array or better a tree of extents that
list which indexes correspond to which swap pages.  With some
pages not being backed.

Getting the allocation of indices correct so that merging will work
is a little trickier then now, as is the case of a private writeable
mapping of a file.  But in a lot of other ways the logic becomes
simpler.
 
> For 2.5 I'm making a VM subsystem with reverse mappings, the
> first iterations are giving very sweet performance so I will
> continue with this project regardless of what other kernel
> hackers might say ;)

Do you have any arguments for the reverse mappings or just for some of
the other side effects that go along with them?

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
