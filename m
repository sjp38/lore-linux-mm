Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6C55D6B01BB
	for <linux-mm@kvack.org>; Wed, 26 May 2010 23:45:44 -0400 (EDT)
Received: by qyk28 with SMTP id 28so11052913qyk.26
        for <linux-mm@kvack.org>; Wed, 26 May 2010 20:45:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1005211410170.14789@sister.anvils>
References: <AANLkTimAF1zxXlnEavXSnlKTkQgGD0u9UqCtUVT_r9jV@mail.gmail.com>
	<AANLkTimUYmUCdFMIaVi1qqcz2DqGoILeu43XWZBHSILP@mail.gmail.com>
	<AANLkTilmr29Vv3N64n7KVj9fSDpfBHIt8-quxtEwY0_X@mail.gmail.com>
	<alpine.LSU.2.00.1005211410170.14789@sister.anvils>
From: dave b <db.pub.mail@gmail.com>
Date: Thu, 27 May 2010 13:45:23 +1000
Message-ID: <AANLkTil8sEzrsC9If5HdU8S5R-sK84_fUt_BXUDcAu0J@mail.gmail.com>
Subject: Re: PROBLEM: oom killer and swap weirdness on 2.6.3* kernels
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

That was just a simple test case with dd. That test case might be
invalid - but it is trying to trigger out of memory - doing this any
other way still causes the problem. I note that playing with some bios
settings I was actually able to trigger what appeared to be graphics
corruption issues when I launched kde applications ... nothing shows
up in dmesg so this might just be a conflict between xorg and the
kernel with those bios settings...

Anyway, This is no longer a 'problem' for me since I disabled
overcommit and altered the values for dirty_ratio and
dirty_background_ratio - and I cannot trigger it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
