Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id B6CD039269
	for <linux-mm@kvack.org>; Thu, 19 Sep 2002 12:13:27 -0300 (EST)
Date: Thu, 19 Sep 2002 12:13:23 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.5.36-mm1
In-Reply-To: <20020919150959.GA1887@prester.hh59.org>
Message-ID: <Pine.LNX.4.44L.0209191212580.1519-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: axel@hh59.org
Cc: Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Sep 2002 axel@hh59.org wrote:

> Well. I have retrieved procps from CVS and built it. But then vmstat
> gets an segmentation fault. It looks like this..
>
> prester:/root# vmstat
>    procs                      memory      swap          io     system
> cpu
>  r  b  w   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy
> id
> Segmentation fault
> Exit 139

You made sure to run it with the _new_ libproc and not with
the old one you still have in /lib ?

Rik
-- 
Spamtrap of the month: september@surriel.com

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
