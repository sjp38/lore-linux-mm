Date: Thu, 21 Sep 2000 15:23:17 -0700
Message-Id: <200009212223.PAA04238@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: 
	<Pine.LNX.4.21.0009211340110.18809-100000@duckman.distro.conectiva>
	(message from Rik van Riel on Thu, 21 Sep 2000 13:44:35 -0300 (BRST))
Subject: Re: [patch *] VM deadlock fix
References: <Pine.LNX.4.21.0009211340110.18809-100000@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br
Cc: torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

How did you get away with adding a new member to task_struct yet not
updating the INIT_TASK() macro appropriately? :-)  Does it really
compile?

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
