Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DEABE900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 21:13:01 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <07301036-485e-4b0e-88db-7937857d1977@default>
Date: Thu, 23 Jun 2011 18:12:01 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: Re: [PATCH] fix cleancache config
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rolf Eike Beer <eike-kernel@sf-tec.de>
Cc: linux-mm <linux-mm@kvack.org>

> It doesn't make sense to have a default setting different to that what we
> suggest the user to select.

Even when configured on at compile time, cleancache functionality
is inert unless the hooks are registered by a "backend" (e.g.
zcache or Xen or other future code).   If configured on,
a backend module can dynamically enable cleancache functionality;
the cost is extremely small, so all postings of cleancache
had "default y".

Just before Linus merged cleancache, he insisted that the
default be changed to "n".  I didn't argue, just changed it.
However, I think in the future most distros will prefer to
have it set so the functionality can be enabled at runtime,
thus the help comment is inconsistent with the default.

> Also fixes a typo.

Don't know how I missed that one :-}  Typo fix:

Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
