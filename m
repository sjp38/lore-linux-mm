Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 72C4138DEB
	for <linux-mm@kvack.org>; Tue, 14 May 2002 13:36:11 -0300 (EST)
Date: Tue, 14 May 2002 13:36:00 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC][PATCH] iowait statistics
In-Reply-To: <20020514153956.GI15756@holomorphy.com>
Message-ID: <Pine.LNX.4.44L.0205141335080.9490-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 14 May 2002, William Lee Irwin III wrote:
> On Mon, May 13, 2002 at 10:19:26PM -0300, Rik van Riel wrote:
> > 2) if no process is running, the timer interrupt adds a jiffy
> >    to the iowait time
> [...]
> > 4) on SMP systems the iowait time can be overestimated, no big
> >    deal IMHO but cheap suggestions for improvement are welcome
                     ^^^^^
> This appears to be global across all cpu's. Maybe nr_iowait_tasks
> should be accounted on a per-cpu basis, where

While your proposal should work, somehow I doubt it's worth
the complexity. It's just a statistic to help sysadmins ;)

regards,

Rik
-- 
	http://www.linuxsymposium.org/2002/
"You're one of those condescending OLS attendants"
"Here's a nickle kid.  Go buy yourself a real t-shirt"

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
