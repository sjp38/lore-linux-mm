Date: Thu, 22 Mar 2001 13:29:02 -0600
From: Philipp Rumpf <prumpf@mandrakesoft.com>
Subject: Re: [PATCH] Prevent OOM from killing init
Message-ID: <20010322132902.B23177@mandrakesoft.mandrakesoft.com>
References: <Pine.LNX.4.21.0103212047590.19934-100000@imladris.rielhome.conectiva> <m18zly2pam.fsf@frodo.biederman.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m18zly2pam.fsf@frodo.biederman.org>; from Eric W. Biederman on Thu, Mar 22, 2001 at 01:14:41AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 22, 2001 at 01:14:41AM -0700, Eric W. Biederman wrote:
> Rik van Riel <riel@conectiva.com.br> writes:
> Is there ever a case where killing init is the right thing to do?

There are cases where panic() is the right thing to do.  Broken init
is such a case.

> My impression is that if init is selected the whole machine dies.
> If you can kill init and still have a machine that mostly works,

you can't.

> Guaranteeing not to select init can buy you piece of mind because
> init if properly setup can put the machine back together again, while
> not special casing init means something weird might happen and init
> would be selected.

If we're in a situation where long-running processes with relatively
small VM are killed the box is very unlikely to be usable anyway.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
