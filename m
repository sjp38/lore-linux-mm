Date: Fri, 23 Mar 2001 19:31:33 +0200 (MET DST)
From: Szabolcs Szakacsits <szaka@f-secure.com>
Subject: Re: [PATCH] Prevent OOM from killing init
In-Reply-To: <Pine.LNX.4.21.0103212047590.19934-100000@imladris.rielhome.conectiva>
Message-ID: <Pine.LNX.4.30.0103231854470.13864-100000@fs131-224.f-secure.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Mar 2001, Rik van Riel wrote:
> One question ... has the OOM killer ever selected init on
> anybody's system ?

Hi Rik,

When I ported your OOM killer to 2.2.x and integrated it into the
'reserved root memory' [*] patch, during intensive testing I found two
cases when init was killed. It happened on low-end machines and when OOM
killer wasn't triggered so init was killed in the page fault handler.
The later was also one of the reasons I replaced the "random" OOM killer
in page fault handler with yours [so there is only one OOM killer]. I
also asked you at that time whether there was any reason you didn't put
it also there but unfortunately you didn't answer. Practice showed it
works there as well [and actually some crashes that was reported here
recently could have been avoided in this way] but technically maybe I
missed something?

Other things that bothered me,
 - niced processes are penalized
 - trying to kill a task that is permanently in TASK_UNINTERRUPTIBLE
   will probably deadlock the machine [or the random OOM killer will
   kill the box].

	Szaka

[*] who are interested, it can be found at
	http://mlf.linux.rulez.org/mlf/ezaz/reserved_root_memory.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
