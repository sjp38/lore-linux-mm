Date: Thu, 21 Sep 2000 16:57:45 -0700
Message-Id: <200009212357.QAA04772@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <20000922021805.D23007@athlon.random> (message from Andrea
	Arcangeli on Fri, 22 Sep 2000 02:18:05 +0200)
Subject: Re: [patch *] VM deadlock fix
References: <Pine.LNX.4.21.0009211340110.18809-100000@duckman.distro.conectiva> <200009212223.PAA04238@pizda.ninka.net> <20000922021805.D23007@athlon.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: andrea@suse.de
Cc: riel@conectiva.com.br, torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   As far as sleep_time is ok to be set to zero its missing
   initialization is right.

Indeed.

Later,
David S. Miller
davem@redhat.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
