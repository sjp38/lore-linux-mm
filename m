From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14322.39431.416869.698005@dukat.scot.redhat.com>
Date: Thu, 30 Sep 1999 00:00:23 +0100 (BST)
Subject: Re: mm->mmap_sem
In-Reply-To: <Pine.LNX.4.10.9909271527030.7835-100000@imperial.edgeglobal.com>
References: <37EF30FF.456EBA6B@kieray1.p.y.ki.era.ericsson.se>
	<Pine.LNX.4.10.9909271527030.7835-100000@imperial.edgeglobal.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: Marcus Sundberg <erammsu@kieray1.p.y.ki.era.ericsson.se>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 27 Sep 1999 15:31:28 -0400 (EDT), James Simmons
<jsimmons@edgeglobal.com> said:

>> No, you are trying to do _mandatory_ locking enforced by the kernel.
>> For cooperative locking on sane GFX hardware a userspace spinlock is
>> indeed all that is required, but for the broken hardware you are talking
>> about kernel locking would be required.

> What are all the broken cards out their? I was reading my old Matrox
> Millenium I docs and even that card supports similutaneous access to 
> the accel engine and framebuffer. If the number of cards that are that
> broken are small then I just will not support them.

I think that there's a large number of them.  The XI and XFree86 folk
would probably know which ones exactly.

>> This means that when the accel engine is initiated you must unmap all
>> pages of the framebuffer (8k pages on modern cards), install a no-page
>> handler and flush the TLBs of all processors.

> All the processors!! Thats really bad.

Yes.  That is the specific case which makes this impractical to do in
software.  It would be bad enough on one CPU, but having to do it on all
requires sending inter-CPU interrupts, and that is simply too slow for a
fast graphics engine.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
