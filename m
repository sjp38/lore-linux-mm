Date: Wed, 8 Mar 2000 23:39:46 +0100
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: Linux responsiveness under heavy load
Message-ID: <20000308233946.A9644@pcep-jamie.cern.ch>
References: <20000308223851.A9519@pcep-jamie.cern.ch> <Pine.LNX.4.21.0003081920500.4639-100000@duckman.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0003081920500.4639-100000@duckman.conectiva>; from Rik van Riel on Wed, Mar 08, 2000 at 07:26:22PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> > A larger priority for page-in I/O due to interactive process too
> > might help too.  Some modification of Andrea's elevator.  But
> > that doesn't seem so easy.
> 
> Read requests are easily tied to a process, so this could
> be relatively easy. Doing it properly before 2.5 may be a
> little difficult though ...

A simple flag with each I/O request meaning "high priority due to
interactive process I/O".  Make the elevator select high priority
requests before low ones, with the same sequence number bound for
fairness as has recently been implemented.

Maybe even a small holdoff time when going from handling a high priority
to a low priority request, to give the interactive process a few
microseconds to stimulate another page in.  (Actually a small holdoff in
general between I/O "here" and I/O "far away" might improve overall seek
times, orthogonal to priority issues).

It does seem too simple to work, but has anyone tried it?

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
