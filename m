Subject: Re: 2.6.0-test1-mm1
References: <20030715225608.0d3bff77.akpm@osdl.org>
From: Sean Neakums <sneakums@zork.net>
Date: Wed, 16 Jul 2003 09:07:42 +0100
In-Reply-To: <20030715225608.0d3bff77.akpm@osdl.org> (Andrew Morton's
 message of "Tue, 15 Jul 2003 22:56:08 -0700")
Message-ID: <6uwueidhdd.fsf@zork.zork.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Con Kolivas <kernel@kolivas.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@osdl.org> writes:

> . Another interactivity patch from Con.  Feedback is needed on this
>   please - we cannot make much progress on this fairly subjective work
>   without lots of people telling us how it is working for them.

This patch seems to mostly cure an oddity I've been seeing since
2.5.7x, or maybe very late 2.5.6x (I forget exactly when) where
running 'ps aux' or 'ls -l' in an xterm (and only xterm it seems; I've
tried rxvt and aterm) would more often than not result in a wallclock
run time of up to two seconds, instead of the usual tenth of a second
or so, with system and user time remaining constant.  If I keep
running 'ps aux' its output does start to become slow again, snapping
back to full speed after a few more runs.  Kind of an odd one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
