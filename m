Date: Tue, 10 Oct 2000 10:59:47 +0100
From: "J.A. Sutherland" <jas88@cam.ac.uk>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <512978185.971175587@pc357.nmus.pwf.cam.ac.uk>
In-Reply-To: <Pine.LNX.4.21.0010091739570.1562-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>, Andrea Arcangeli <andrea@suse.de>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--On 09 October 2000, 17:40 -0300 Rik van Riel <riel@conectiva.com.br>
wrote:
> On Mon, 9 Oct 2000, James Sutherland wrote:
>> On Mon, 9 Oct 2000, Ingo Molnar wrote:
>> > On Mon, 9 Oct 2000, Rik van Riel wrote:
>> > 
>> > > > so dns helper is killed first, then netscape. (my idea might not
>> > > > make sense though.)
>> > > 
>> > > It makes some sense, but I don't think OOM is something that
>> > > occurs often enough to care about it /that/ much...
>> > 
>> > i'm trying to handle Andrea's case, the init=/bin/bash manual-bootup
>> > case, with 4MB RAM and no swap, where the admin tries to exec a 2MB
>> > process. I think it's a legitimate concern - i cannot know in advance
>> > whether a freshly started process would trigger an OOM or not.
>> 
>> Shouldn't the runtime factor handle this, making sure the new
>> process is killed? (Maybe not if you're almost OOM right from
>> the word go, and run this process straight off... Hrm.)
> 
> It should.
> 
> Also, the example is a tad unrealistic since init seems to be
> around 70 kB in size on my systems ;)

In extreme cases, though, you could arrange things so the
machine only has 100K of RAM when it loads init, at which
point init tries running, say, rc.sysinit - and everything goes 
bang. Of course, a machine like that won't be very much use
anyway...

More realistically, though, I could be running with something
like init=/bin/sash - does your statically linked sash binary
fit in 70K? :-)


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
