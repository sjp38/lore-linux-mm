Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 974E638CC7
	for <linux-mm@kvack.org>; Tue,  7 May 2002 16:49:18 -0300 (EST)
Date: Tue, 7 May 2002 16:49:08 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Why *not* rmap, anyway?
In-Reply-To: <20020507192547.GU15756@holomorphy.com>
Message-ID: <Pine.LNX.4.44L.0205071648210.7447-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Christian Smith <csmith@micromuse.com>, Daniel Phillips <phillips@bonn-fries.net>, Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 May 2002, William Lee Irwin III wrote:

> Procedural interfaces to pagetable manipulations are largely what
> the BSD pmap and SVR4 HAT layers consisted of, no?

Indeed, but there is a difference between:

1) we need to get a proper interface

and

2) we should have 2 sets of data structures, one shadowing the other

I like (1), but have my doubts about (2) ...

cheers,

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
