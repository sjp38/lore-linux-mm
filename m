Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 8DABD6B0068
	for <linux-mm@kvack.org>; Sat, 17 Nov 2012 18:15:17 -0500 (EST)
Received: by mail-oa0-f41.google.com with SMTP id k14so4765060oag.14
        for <linux-mm@kvack.org>; Sat, 17 Nov 2012 15:15:16 -0800 (PST)
Date: Fri, 16 Nov 2012 23:11:07 -0600
From: Rob Landley <rob@landley.net>
Subject: Re: [PATCH] Correct description of SwapFree in
 Documentation/filesystems/proc.txt
In-Reply-To: <50A5E4D6.60301@gmail.com> (from mtk.manpages@gmail.com on Fri
	Nov 16 01:01:42 2012)
Message-Id: <1353129067.19744.1@driftwood>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; DelSp=Yes; Format=Flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Jim Paris <jim@jtan.com>

On 11/16/2012 01:01:42 AM, Michael Kerrisk wrote:
> After migrating most of the information in
> Documentation/filesystems/proc.txt to the proc(5) man page,
> Jim Paris pointed out to me that the description of SwapFree
> in the man page seemed wrong. I think Jim is right,
> but am given pause by fact that that text has been in
> Documentation/filesystems/proc.txt since at least 2.6.0.
> Anyway, I believe that the patch below fixes things.
>=20
> Signed-off-by: Michael Kerrisk <mtk.manpages@gmail.com>

Acked-by: Rob Landley <rob@landley.net>

Want me to forward it on? (Lots of documentation stuff gets grabbed by =20
whoever maintains what it's documenting, this looks like it might fall =20
through the cracks...)

Rob=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
