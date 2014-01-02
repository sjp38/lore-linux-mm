Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f173.google.com (mail-ve0-f173.google.com [209.85.128.173])
	by kanga.kvack.org (Postfix) with ESMTP id 62FF46B0031
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 16:25:46 -0500 (EST)
Received: by mail-ve0-f173.google.com with SMTP id oz11so7672486veb.32
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 13:25:46 -0800 (PST)
Received: from cdptpa-omtalb.mail.rr.com (cdptpa-omtalb.mail.rr.com. [75.180.132.120])
        by mx.google.com with ESMTP id ce7si23727093veb.70.2014.01.02.13.25.45
        for <linux-mm@kvack.org>;
        Thu, 02 Jan 2014 13:25:45 -0800 (PST)
Message-ID: <52C5D953.4030805@ubuntu.com>
Date: Thu, 02 Jan 2014 16:25:39 -0500
From: Phillip Susi <psusi@ubuntu.com>
MIME-Version: 1.0
Subject: Re: [RFC] [PATCH v5 0/3] fadvise: support POSIX_FADV_NOREUSE
References: <1329006098-5454-1-git-send-email-andrea@betterlinux.com> <20120214133337.9de7835b.akpm@linux-foundation.org> <20120214225922.GA12394@thinkpad> <20120214152220.4f621975.akpm@linux-foundation.org> <20120215012957.GA1728@thinkpad> <20120216084831.0a6ef4f2.kamezawa.hiroyu@jp.fujitsu.com> <20120216004342.GB21685@thinkpad>
In-Reply-To: <20120216004342.GB21685@thinkpad>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <andrea@betterlinux.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Shaohua Li <shaohua.li@intel.com>, =?ISO-8859-1?Q?P=E1draig_Brady?= <P@draigBrady.com>, John Stultz <john.stultz@linaro.org>, Jerry James <jamesjer@betterlinux.com>, Julius Plenz <julius@plenz.com>, Greg Thelen <gthelen@google.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

What ever happened to this patch set?  It looks like a great idea to
me and I'd *really* like to see this flag implemented.


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (MingW32)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJSxdlTAAoJEI5FoCIzSKrw0O0H/3cIe/XvrXvF6qzgHpQPIfnN
a+14iqUa5+fNKNRM0Rwk9Tb3EFUjIXKHcRiRzGD9CINVxonBQQME68KA94UxVZIL
oul4YMP4dNcBhp8Ux1M80JY3Y/CMSo9SAN1pc7bmIezua/v821vb6wgCamj3EnS5
/Zs51cIWMkRSAr7EVvycI6mI04MzqsEdtGHdI0U6jrLjLLHsEgbuqkBMrc5BNkQ/
3tD6atY5zNyBIl+RBOvukNoijtEW4Z5OU+zfZHSk/L72yZnl+17nz4mRApmikUDV
zhJoCheWqLCLtpg2SxVC/EMUS3TDy3k9+8zQHbRZ3igXP4e58NZFR+XC1JhVonQ=
=TqVD
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
