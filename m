Received: from ukaea.org.uk ([194.128.63.74])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA29648
	for <linux-mm@kvack.org>; Mon, 7 Dec 1998 05:49:40 -0500
Message-Id: <98Dec7.104648gmt.66310@gateway.ukaea.org.uk>
Date: Mon, 7 Dec 1998 10:47:42 +0000
From: Neil Conway <nconway.list@ukaea.org.uk>
MIME-Version: 1.0
Subject: Re: [PATCH] VM improvements for 2.1.131
References: <Pine.LNX.3.96.981206011441.13041A-100000@mirkwood.dummy.home>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Won't making the min_percent values (cache/buffers) equal to 1% wreck
performance on small memory machines?

Neil
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
