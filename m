Date: Thu, 22 Mar 2001 22:20:22 +0000 (GMT)
From: "James A. Sutherland" <jas88@cam.ac.uk>
Subject: Re: [PATCH] Prevent OOM from killing init
In-Reply-To: <Pine.LNX.4.21.0103212047590.19934-100000@imladris.rielhome.conectiva>
Message-ID: <Pine.LNX.4.30.0103222218220.2992-100000@dax.joh.cam.ac.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Mar 2001, Rik van Riel wrote:

> On Wed, 21 Mar 2001, Patrick O'Rourke wrote:
>
> > Since the system will panic if the init process is chosen by
> > the OOM killer, the following patch prevents select_bad_process()
> > from picking init.
>
> One question ... has the OOM killer ever selected init on
> anybody's system ?

Well, I managed to get the OOM killer killing init once; OTOH, I had just
broken MM completely (disabled freeing of pages entirely!) so that doesn't
really count, I think :-)

> I think that the scoring algorithm should make sure that
> we never pick init, unless the system is screwed so badly
> that init is broken or the only process left ;)

If the system is that badly screwed, killing init is probably the right
thing to do, since this should then cause a panic, and thus a reboot if
the machine is so configured?


James.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
