Subject: Re: [PATCH] Prevent OOM from killing init
References: <Pine.LNX.4.21.0103212047590.19934-100000@imladris.rielhome.conectiva>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 22 Mar 2001 01:14:41 -0700
In-Reply-To: Rik van Riel's message of "Wed, 21 Mar 2001 20:48:54 -0300 (BRST)"
Message-ID: <m18zly2pam.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> On Wed, 21 Mar 2001, Patrick O'Rourke wrote:
> 
> > Since the system will panic if the init process is chosen by
> > the OOM killer, the following patch prevents select_bad_process()
> > from picking init.
> 
> One question ... has the OOM killer ever selected init on
> anybody's system ?
> 
> I think that the scoring algorithm should make sure that
> we never pick init, unless the system is screwed so badly
> that init is broken or the only process left ;)

Is there ever a case where killing init is the right thing to do?
My impression is that if init is selected the whole machine dies.
If you can kill init and still have a machine that mostly works,
then I guess it makes some sense not to kill it.

Guaranteeing not to select init can buy you piece of mind because
init if properly setup can put the machine back together again, while
not special casing init means something weird might happen and init
would be selected.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
