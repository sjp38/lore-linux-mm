Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Subject: RE: Correctly determine free memory amount before swapping
Date: Mon, 13 Dec 2004 08:32:24 +0200
Message-ID: <06EF4EE36118C94BB3331391E2CDAAD9D4A41F@exil1.paradigmgeo.net>
From: "Gregory Giguashvili" <Gregoryg@ParadigmGeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I need to commit the largest chunk of memory in the quickest way. This
operation may
> be slowed down by swapping - that's why I don't want to get there.
Could any of MM people throw a short comment on this? If a rough
estimation is impossible to give in Linux, it would be great to know
that.

Thanks in advance,
Giga
P.S. If I'm not asking this question in the right mailing list, please,
let me know.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
