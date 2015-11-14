Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f47.google.com (mail-lf0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id C1B576B0266
	for <linux-mm@kvack.org>; Sat, 14 Nov 2015 15:40:42 -0500 (EST)
Received: by lfs39 with SMTP id 39so68944287lfs.3
        for <linux-mm@kvack.org>; Sat, 14 Nov 2015 12:40:42 -0800 (PST)
Received: from mail-lf0-x22f.google.com (mail-lf0-x22f.google.com. [2a00:1450:4010:c07::22f])
        by mx.google.com with ESMTPS id a195si19771639lfe.143.2015.11.14.12.40.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Nov 2015 12:40:40 -0800 (PST)
Received: by lfs39 with SMTP id 39so68944162lfs.3
        for <linux-mm@kvack.org>; Sat, 14 Nov 2015 12:40:40 -0800 (PST)
From: Arkadiusz =?utf-8?q?Mi=C5=9Bkiewicz?= <arekm@maven.pl>
Subject: Re: memory reclaim problems on fs usage
Date: Sat, 14 Nov 2015 21:40:38 +0100
References: <201511102313.36685.arekm@maven.pl> <56449E44.7020407@I-love.SAKURA.ne.jp> <201511122228.26399.arekm@maven.pl>
In-Reply-To: <201511122228.26399.arekm@maven.pl>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201511142140.38245.arekm@maven.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, xfs@oss.sgi.com

On Thursday 12 of November 2015, Arkadiusz Mi=C5=9Bkiewicz wrote:
> On Thursday 12 of November 2015, Tetsuo Handa wrote:
> > On 2015/11/12 15:06, Arkadiusz Mi=C5=9Bkiewicz wrote:
> > > On Wednesday 11 of November 2015, Tetsuo Handa wrote:
> > >> Arkadiusz Mi?kiewicz wrote:
> > >>> This patch is against which tree? (tried 4.1, 4.2 and 4.3)
> > >>=20
> > >> Oops. Whitespace-damaged. This patch is for vanilla 4.1.2.
> > >> Reposting with one condition corrected.
> > >=20
> > > Here is log:
> > >=20
> > > http://ixion.pld-linux.org/~arekm/log-mm-1.txt.gz
> > >=20
> > > Uncompresses is 1.4MB, so not posting here.
> >=20
> > Thank you for the log. The result is unexpected for me.
>=20
> [...]
>=20
> > vmstat_update() and submit_flushes() remained pending for about 110
> > seconds. If xlog_cil_push_work() were spinning inside GFP_NOFS
> > allocation, it should be reported as MemAlloc: traces, but no such lines
> > are recorded. I don't know why xlog_cil_push_work() did not call
> > schedule() for so long. Anyway, applying
> > http://lkml.kernel.org/r/20151111160336.GD1432@dhcp22.suse.cz should
> > solve vmstat_update() part.
>=20
> To apply that patch on top of 4.1.13 I also had to apply patches listed
> below.
>=20
> So in summary appllied:
> http://sprunge.us/GYBb
> http://sprunge.us/XWUX
> http://sprunge.us/jZjV

I've tried more to trigger "page allocation failure" with usual actions tha=
t=20
triggered it previously but couldn't reproduce. With these patches applied =
it=20
doesn't happen.

Logs from my tests:

http://ixion.pld-linux.org/~arekm/log-mm-3.txt.gz
http://ixion.pld-linux.org/~arekm/log-mm-4.txt.gz (with swap added)

But are these patches solving the problem or just hiding it?

=2D-=20
Arkadiusz Mi=C5=9Bkiewicz, arekm / ( maven.pl | pld-linux.org )

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
