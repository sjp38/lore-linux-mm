Content-Type: text/plain;
  charset="iso-8859-1"
From: Jordi Polo <mumismo@wanadoo.es>
Subject: Re: [PATCH] Prevent OOM from killing init
Date: Fri, 23 Mar 2001 21:16:21 +0100
References: <Pine.LNX.4.30.0103231721480.4103-100000@dax.joh.cam.ac.uk>
In-Reply-To: <Pine.LNX.4.30.0103231721480.4103-100000@dax.joh.cam.ac.uk>
MIME-Version: 1.0
Message-Id: <01032321162101.00471@mioooldpc>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "James A. Sutherland" <jas88@cam.ac.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> What on earth did you expect to happen when the process exceeded the
> machine's capabilities? Using more than all the resources fails. There
> isn't an alternative.

I'll be burnt in fire if i say this but anyway ..... we need the window's 
system , a dinamic grownable swap  .  And if we have no HD then oom kill 
(letting the administrator what processes never be killed by it).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
