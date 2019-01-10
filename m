Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8E8408E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 17:33:27 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id b16so13227899qtc.22
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 14:33:27 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f27sor67617592qve.46.2019.01.10.14.33.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 14:33:26 -0800 (PST)
Message-ID: <1547159604.6911.12.camel@lca.pw>
Subject: Re: PROBLEM: syzkaller found / pool corruption-overwrite / page in
 user-area or NULL
From: Qian Cai <cai@lca.pw>
Date: Thu, 10 Jan 2019 17:33:24 -0500
In-Reply-To: <hFmbfypBKySVyM6ITf55xUsPWifgqJy6MZ-kFJcYna61S-u2hoClrqr87QTF4F2LhW-K42T2lcCbvsEyGAL0dJTq5CndQBiMT6JnlW4xmdc=@protonmail.ch>
References: 
	<t78EEfgpy3uIwPUvqvmuQEYEWKG9avWzjUD3EyR93Qaf_tfx1gqt4XplrqMgdxR1U9SsrVdA7G9XeUZacgUin0n6lBzoxJHVJ9Ko0yzzrxI=@protonmail.ch>
	 <1547150339.2814.9.camel@linux.ibm.com> <1547153074.6911.8.camel@lca.pw>
	 <4u36JfbOrbu9CXLDErzQKvorP0gc2CzyGe60rBmZsGAGIw6RacZnIfoSsAF0I0TCnVx0OvcqCZFN6ntbgicJ66cWew9cOXRgcuWxSPdL3ko=@protonmail.ch>
	 <1547154231.6911.10.camel@lca.pw>
	 <hFmbfypBKySVyM6ITf55xUsPWifgqJy6MZ-kFJcYna61S-u2hoClrqr87QTF4F2LhW-K42T2lcCbvsEyGAL0dJTq5CndQBiMT6JnlW4xmdc=@protonmail.ch>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Esme <esploit@protonmail.ch>
Cc: James Bottomley <jejb@linux.ibm.com>, "dgilbert@interlog.com" <dgilbert@interlog.com>, "martin.petersen@oracle.com" <martin.petersen@oracle.com>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 2019-01-10 at 21:35 +0000, Esme wrote:
> The repro.report is from a different test system, I pulled the attached config
> from proc (attached);
> 

So, if the report is not right one. Where is the right crash stack trace then
that using the exact same config.?
