Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 1DB99391E0
	for <linux-mm@kvack.org>; Wed, 24 Apr 2002 11:52:57 -0300 (EST)
Date: Wed, 24 Apr 2002 11:52:43 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Why *not* rmap, anyway?
In-Reply-To: <87k7qxuprj.fsf@fadata.bg>
Message-ID: <Pine.LNX.4.44L.0204241152100.7447-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Momchil Velikov <velco@fadata.bg>
Cc: Christian Smith <csmith@micromuse.com>, Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 24 Apr 2002, Momchil Velikov wrote:

> Rik> You really need to read the pmap code and interface instead
> Rik> of repeating the statements made by other people. Have you
> Rik> ever taken a close look at the overhead implicit in the pmap
> Rik> layer ?
>
> Actually, on ia32, there's no reason for the pmap layer to be any
> different than the Linux radix tree. The overhead argument does not
> stand.

So how do you run a pmap VM without duplicating the data from
the pmap layer into the page tables ?

Remember that for VM info the page tables -are- the radix tree.

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
