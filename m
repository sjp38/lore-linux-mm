Message-ID: <27525795B28BD311B28D00500481B7601F107E@ftrs1.intranet.ftr.nl>
From: "Heusden, Folkert van" <f.v.heusden@ftr.nl>
Subject: RE: [PATCH] Prevent OOM from killing init
Date: Fri, 23 Mar 2001 10:28:50 +0100
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Tom Kondilis <tomk@plaza.ds.adp.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> That's not the OOM killer however, but init dying because it
> couldn't get the memory it needed to satisfy a page fault or
> somesuch...

Ehrm, I would like to re-state that it still would be nice if
some mechanism got introduced which enables one to set certain
processes to "cannot be killed".
For example: I would hate it it the UPS monitoring daemon got
killed for obvious reasons :o)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
