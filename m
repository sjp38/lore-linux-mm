From: "Christian Bodmer" <cbinsec01@freesurf.ch>
Date: Thu, 22 Mar 2001 19:32:29 +0100
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7BIT
Subject: Re: [PATCH] Prevent OOM from killing init
Message-ID: <3ABA534D.2392.3D7585@localhost>
References: <4605B269DB001E4299157DD1569079D2809930@EXCHANGE03.plaza.ds.adp.com>
In-reply-to: <Pine.LNX.4.21.0103221329000.21415-100000@imladris.rielhome.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I can't say I understand the whole MM system, however the random killing of 
processes seems like a rather unfortunate solution to the problem. If someone 
has a spare minute, maybe they could explain to me why running out of free 
memory in kswapd results in a deadlock situation.

That aside, would it be an improvement to define another process flag 
(PF_OOMPRESERVE) that would declare a process as undesirable to be killed in an 
OOM situation, so that the user has at least some control over what gets killed 
first or last respectively. Only when select_bad_process() runs out of 
unflagged processes will it then proceed to kill the processes with this new 
flag.

Just an idea, I am pretty sure there's tons of reasons why not to introduce a 
new per process flag.

/Cheers
Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
