Date: Mon, 9 Oct 2000 07:27:57 -0400 (EDT)
From: Byron Stanoszek <gandalf@winds.org>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <Pine.LNX.4.21.0010091159430.20087-100000@Megathlon.ESI>
Message-ID: <Pine.LNX.4.21.0010090722300.5489-100000@winds.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marco Colombo <marco@esi.it>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Marco Colombo wrote:

> On Fri, 6 Oct 2000, Rik van Riel wrote:
> 
> [...]
> > They are niced because the user thinks them a bit less
> > important. 
> 
> Please don't, this assumption is quite wrong. I use nice just to be
> 'nice' to other users. I can run my *important* CPU hog simulation
> nice +10 in order to let other people get more CPU when the need it.
> But if you put the logic "niced == not important" somewhere into the
> kernel, nobody will use nice anymore. I'd rather give a bonus to niced
> processes.
> 
> I agree this is a small issue, the OOM killer job isn't "nice" at all
> anyway. B-) (at OOM time, I'd not even look at the nice of a process at
> all. But my point here is that you do, and you take it as an hint for
> process importance as percieved by the user that run it, and I believe
> it's just wrong guessing).

I agree completely. Friday night I had a talk with a few others at the office,
and we all came to a concensus that the 'nice' value really shouldn't be a
factor to determine which process gets killed first. The primary point was
that 'nice' is most commonly used for background tasks that are meant to run in
hidden and unseen with low priority. It would be extremely upsetting if a user
decided to log in and browse 50 picture-intensive pages with netscape,
racking up the memory over time, and allowing the OOM killer to zap the
peaceful, 'nice' process in the background that wasn't causing any harm.

Why else would you nice a process? Because you don't want it to interfere with
normal cpu usage by those that normally use the system. You expect that process
to still be running at the end of the day when everyone's gone home.

Regards,
 Byron

-- 
Byron Stanoszek                         Ph: (330) 644-3059
Systems Programmer                      Fax: (330) 644-8110
Commercial Timesharing Inc.             Email: bstanoszek@comtime.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
