Received: from lappi.waldorf-gmbh.de (cs7-7.modems.unam.mx [132.248.134.78])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA00294
	for <linux-mm@kvack.org>; Thu, 26 Nov 1998 06:45:22 -0500
Message-ID: <19981125103132.H350@uni-koblenz.de>
Date: Wed, 25 Nov 1998 10:31:32 -0600
From: ralf@uni-koblenz.de
Subject: Re: Two naive questions and a suggestion
References: <19981119002037.1785.qmail@sidney.remcomp.fr> <199811231808.SAA21383@dax.scot.redhat.com> <19981123215933.2401.qmail@sidney.remcomp.fr> <199811241117.LAA06562@dax.scot.redhat.com> <19981124214432.2922.qmail@sidney.remcomp.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <19981124214432.2922.qmail@sidney.remcomp.fr>; from jfm2@club-internet.fr on Tue, Nov 24, 1998 at 09:44:32PM -0000
Sender: owner-linux-mm@kvack.org
To: jfm2@club-internet.fr, sct@redhat.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 24, 1998 at 09:44:32PM -0000, jfm2@club-internet.fr wrote:

> In situation like those above I would like Linux supported a concept
> like guaranteed processses: if VM is exhausted by one of them then try
> to get memory by killing non guaranteed processes and only kill the
> original one if all reamining survivors are guaranteed ones.
> It would be better for mission critical tasks.

Long time ago I suggested to make it configurable whether a process gets
memory which might be overcommited or not.  This leaves malloc(x) == NULL
to deal with and that's a userland problem anyway.

  Ralf
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
