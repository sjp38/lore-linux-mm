Date: Wed, 26 Apr 2000 08:28:21 -0700
Message-Id: <200004261528.IAA13982@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <oupbt2wombt.fsf@pigdrop.muc.suse.de> (message from Andi Kleen on
	26 Apr 2000 18:31:50 +0200)
Subject: Re: [PATCH] 2.3.99-pre6-3+  VM rebalancing
References: <Pine.LNX.4.21.0004261041420.16202-100000@duckman.conectiva> <200004261433.HAA13894@pizda.ninka.net> <oupbt2wombt.fsf@pigdrop.muc.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ak@suse.de
Cc: riel@conectiva.com.br, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   But is that still fair ? A memory hog could rapidly allocate and
   dirty pages, killing the small innocent daemon which just needs to
   get some work done.

If the daemon is actually doing anything, he'll reference his
pages which will cause us to not liberate them.  If he's not doing
anything, why should we keep his pages around?

Later,
David S. Miller
davem@redhat.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
