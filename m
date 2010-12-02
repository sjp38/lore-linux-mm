Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 274588D000E
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 00:13:19 -0500 (EST)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id oB25DDjJ010604
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 21:13:14 -0800
Received: by iwn41 with SMTP id 41so897780iwn.14
        for <linux-mm@kvack.org>; Wed, 01 Dec 2010 21:13:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <373935679.1026851291266446567.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
References: <1043135380.1026761291266384009.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
 <373935679.1026851291266446567.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 1 Dec 2010 21:12:53 -0800
Message-ID: <AANLkTi=Fy0sqDNai4SUuzvJ+5-+c5EjVLtuozOr_Fkgk@mail.gmail.com>
Subject: Re: oom is broken in mmotm 2010-11-09-15-31 tree?
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: caiqian@redhat.com
Cc: linux-mm <linux-mm@kvack.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 1, 2010 at 9:07 PM,  <caiqian@redhat.com> wrote:
>
>> [ =A0580.192024] =A0 =A0 =A0 =A0 =A0kswapd0 =A0 =A033 =A0 =A0 49939.2367=
93 =A0 =A0 =A05021 =A0 120
>> =A0 =A0 49939.236793 =A0 =A0 39855.128906 =A0 =A0456899.562827 /
> Follow-up on this, kswapd0 was doing this from SysRq-T output,

Ok, this does seem like a lot of pages are busy, so shrink_page_list
ends up just looping.

And that is indeed the bug that commit d88c0922fa0e should have fixed.

So please check whether the kernel you are running has that fix
applied to it or not.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
