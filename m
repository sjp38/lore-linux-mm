From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Date: Mon, 9 Oct 2000 13:47:28 -0400
Content-Type: text/plain
References: <Pine.LNX.4.10.10010091319360.29405-100000@coffee.psychology.mcmaster.ca>
In-Reply-To: <Pine.LNX.4.10.10010091319360.29405-100000@coffee.psychology.mcmaster.ca>
MIME-Version: 1.0
Message-Id: <00100913472801.03825@oscar>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>, Ingo Molnar <mingo@elte.hu>
Cc: Marco Colombo <marco@esi.it>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 09 Oct 2000, Mark Hahn wrote:
> > feature. Rather introduce a orthogonal voluntary "importance"
> > system-call, which marks processes as more and less important. This is
> > similar to priority, it can only be decreased by ordinary users.
>
> nice!  call it CAP_IMPORTANT ;)
> come to think of it, I'm not sure more than one bit would be terribly
> useful - no any sane person is going to spend time
> sorting all their processes by importance...

What about the AIX way?  When the system is nearly OOM it sends a
SIG_DANGER signal to all processes.  Those that handle the signal are not 
initial targets for OOM...  Also in the SIG_DANGER processing they can take 
there own actions to reduce their memory usage... (we would have to look out 
for a SIG_DANGER handler that had a memory leak though)

Ed Tomlinson 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
