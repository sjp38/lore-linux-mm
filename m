Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: [PATCH] add callback back to slab pruning
Date: Sun, 29 Sep 2002 14:38:16 -0400
References: <20020928234930.F13817@bitchcake.off.net> <200209290931.29653.tomlins@cam.org> <3D9720AB.BB226D58@digeo.com>
In-Reply-To: <3D9720AB.BB226D58@digeo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200209291438.16022.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On September 29, 2002 11:47 am, Andrew Morton wrote:
> Ed Tomlinson wrote:
> > Hi Andrew,
> >
> > I posted this Thursday but it seems to have gotten lost in
> > the storm of messages on slab.
>
> Ah, sorry, I neglected to answer.  Yes, I have been testing
> this for a few days, works fine thanks.

Been busy have you?  <grin>

> Calling out to the shrinker to find out how many objects
> they have is sneaky.

Yes.  However it does let us have the ratio calculation in one place
in vmscan.

> I haven't looked super-closely at the code, but it'd be nice
> to make shrinker_lock go away ;)

Will keep this in mind.

Thanks
Ed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
