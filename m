Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id D103D6B000D
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 05:20:52 -0500 (EST)
Received: by mail-qe0-f42.google.com with SMTP id 2so810209qeb.29
        for <linux-mm@kvack.org>; Thu, 31 Jan 2013 02:20:51 -0800 (PST)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <CA+icZUVHrGcGnRcBQF1HLsR4HKOjLsOi6MppPnZCuh8K=wMHmA@mail.gmail.com>
References: <CA+icZUVHrGcGnRcBQF1HLsR4HKOjLsOi6MppPnZCuh8K=wMHmA@mail.gmail.com>
Date: Thu, 31 Jan 2013 11:20:51 +0100
Message-ID: <CA+icZUXohY0dS8o67vy6UrZSnWUc0pjTYdY6aJm3w2umYETEfw@mail.gmail.com>
Subject: Re: BUG: circular locking dependency detected
From: Sedat Dilek <sedat.dilek@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Dave Airlie <airlied@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, DRI <dri-devel@lists.freedesktop.org>, linux-fbdev@vger.kernel.org, linux-next <linux-next@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Takashi Iwai <tiwai@suse.de>, gregkh@linuxfoundation.org, Borislav Petkov <bp@alien8.de>

On Thu, Jan 31, 2013 at 11:12 AM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
> [ CCing Linux-Next and MMOTM folks ]
>
> Original posting from Daniel see [0]
>
> [ QUOTE ]
> On Thu, Jan 31, 2013 at 6:40 AM, Greg Kroah-Hartman
> <gregkh@linuxfoundation.org> wrote:
>> On Thu, Jan 31, 2013 at 11:26:53AM +1100, Linus Torvalds wrote:
>>> On Thu, Jan 31, 2013 at 11:13 AM, Russell King <rmk@arm.linux.org.uk> wrote:
>>> >
>>> > Which may or may not be a good thing depending how you look at it; it
>>> > means that once your kernel blanks, you get a lockdep dump.  At that
>>> > point you lose lockdep checking for everything else because lockdep
>>> > disables itself after the first dump.
>>>
>>> Fair enough, we may want to revert the lockdep checking for
>>> console_lock, and make re-enabling it part of the patch-series that
>>> fixes the locking.
>>>
>>> Daniel/Dave? Does that sound reasonable?
>
> Yeah, sounds good.
>
>> Reverting the patch is fine with me.  Just let me know so I can queue it
>> up again for 3.9.
>
> Can you please also pick up the (currently) three locking fixups
> around fbcon? Just so that we don't repeat the same fun where people
> complain about lockdep splats, but the fixes are stuck somewhere. And
> I guess Dave would be happy to not end up as fbcon maintainer ;-) He
> has a git branch with them at
> http://cgit.freedesktop.org/~airlied/linux/log/?h=fbcon-locking-fixes
> though I have a small bikeshed on his last patch pending.
> -Daniel
> [ /QUOTE ]
>
> Did the 3rd patch go also to mmotm tree and got marked for Linux-Next inclusion?
> Best would be to have it in mainline, finally.
> Please, fix that for-3.8!
>
> Thanks to all volunteers (Alan, Andrew, Takashi Iwai (Sorry, dunno
> which is 1st and last name), Daniel and finally Dave) trying to get
> this incredible pain-in-the-a** upstream :-).
>
> - Sedat -
>
> [0] http://marc.info/?l=dri-devel&m=135962051326601&w=2
> [1] http://cgit.freedesktop.org/~airlied/linux/log/?h=fbcon-locking-fixes
> [2] http://cgit.freedesktop.org/~airlied/linux/commit/?h=fbcon-locking-fixes&id=98dfe36b5532576dedf41408d5bbd45fa31ec62d

[ Adjusting outdated email-adresses, CC Borislav ]

What's with the patch from [3] in mmotm? For-3.8, no more needed?

- Sedat -

[3] http://ozlabs.org/~akpm/mmots/broken-out/drm-fb-helper-dont-sleep-for-screen-unblank-when-an-oopps-is-in-progress.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
