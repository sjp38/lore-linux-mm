Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0BDC78D003B
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 17:20:08 -0500 (EST)
MIME-Version: 1.0
Message-ID: <c9d3fdd6-fec4-47e6-ab21-c8439d32de3a@default>
Date: Fri, 4 Feb 2011 14:17:02 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V1 3/3] drivers/staging: kztmem: misc build/config
References: <20110118172151.GA20507@ca-server1.us.oracle.com
 20110204212843.GA18924@kroah.com>
In-Reply-To: <20110204212843.GA18924@kroah.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <greg@kroah.com>
Cc: gregkh@suse.de, Chris Mason <chris.mason@oracle.com>, akpm@linux-foundation.org, torvalds@linux-foundation.org, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, riel@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>, mel@csn.ul.ie, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, sfr@canb.auug.org.au, wfg@mail.ustc.edu.cn, tytso@mit.edu, viro@ZenIV.linux.org.uk, hughd@google.com, hannes@cmpxchg.org

> If you require a kbuild dependancy, then put it in your Kconfig file
> please, don't break the build.
>=20
> I'll not apply these patches for now until that's fixed up.

Oops, sorry, missed that line in my Kconfig.  Will re-post.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
