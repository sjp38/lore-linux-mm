Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA18193
	for <linux-mm@kvack.org>; Mon, 23 Mar 1998 15:41:16 -0500
Date: Mon, 23 Mar 1998 20:39:26 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: 2.1.90 dies with many procs procs, partial fix
In-Reply-To: <Pine.LNX.3.95.980322022425.5774A-100000@lucifer.guardian.no>
Message-ID: <Pine.LNX.3.91.980323203732.771G-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Finn Arne Gangstad <finnag@guardian.no>
Cc: Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 22 Mar 1998, Finn Arne Gangstad wrote:

> int main() {
> 	int procs = 0;
> 	while (1) {
> 		int err = fork();
> 		if (err == -1) {
> 			perror("fork failed. eek.");
> 			exit(EXIT_FAILURE);
> 		} else if (err == 0) {
> 			setsid();
> 			pause();
> 			_exit(EXIT_SUCCESS);
> 		}
> 		++procs;
> 		printf("%d children forked off\n", procs);
> 		usleep(30000);
> 	}
> 	exit(EXIT_SUCCESS);
> }

Hmm, this is evidence that I was right when I said
that the free_memory_available() system combined
with our current allocation scheme gives trouble.
Linus, what fix do you propose?
(I don't really feel like coding a fix that will
be rejected :-)

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+
