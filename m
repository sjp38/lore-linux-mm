Date: Thu, 22 Mar 2001 13:24:14 -0600
From: Philipp Rumpf <prumpf@mandrakesoft.com>
Subject: Re: [PATCH] Prevent OOM from killing init
Message-ID: <20010322132414.A23177@mandrakesoft.mandrakesoft.com>
References: <3AB9313C.1020909@missioncriticallinux.com> <Pine.LNX.4.21.0103212047590.19934-100000@imladris.rielhome.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0103212047590.19934-100000@imladris.rielhome.conectiva>; from Rik van Riel on Wed, Mar 21, 2001 at 08:48:54PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 21, 2001 at 08:48:54PM -0300, Rik van Riel wrote:
> On Wed, 21 Mar 2001, Patrick O'Rourke wrote:
> 
> > Since the system will panic if the init process is chosen by
> > the OOM killer, the following patch prevents select_bad_process()
> > from picking init.
> 
> One question ... has the OOM killer ever selected init on
> anybody's system ?

Yes, I managed to reproduce this a while ago.  (init was the only
process around though).

We don't ever kill init, fwiw;  we panic(), which is the right thing
to do if init can't keep running.

> I think that the scoring algorithm should make sure that
> we never pick init, unless the system is screwed so badly
> that init is broken or the only process left ;)

I can't think of a situation where the OOM killer does the wrong thing.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
