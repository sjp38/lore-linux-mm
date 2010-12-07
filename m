Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 75F416B0087
	for <linux-mm@kvack.org>; Mon,  6 Dec 2010 20:52:59 -0500 (EST)
Received: by qwg5 with SMTP id 5so11984538qwg.31
        for <linux-mm@kvack.org>; Mon, 06 Dec 2010 17:52:55 -0800 (PST)
From: Ben Gamari <bgamari.foss@gmail.com>
Subject: Re: [PATCH v4 0/7] f/madivse(DONTNEED) support
In-Reply-To: <AANLkTim71krrCcmhTTCZTzxeUDkvOdBTOkeYQu6EXt32@mail.gmail.com>
References: <cover.1291568905.git.minchan.kim@gmail.com> <AANLkTim71krrCcmhTTCZTzxeUDkvOdBTOkeYQu6EXt32@mail.gmail.com>
Date: Mon, 06 Dec 2010 20:52:52 -0500
Message-ID: <87mxoi9wnf.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-=-=

On Tue, 7 Dec 2010 09:24:54 +0900, Minchan Kim <minchan.kim@gmail.com> wrote:
> Sorry missing you in Cc.
> 
> Ben. Could you test this series?
> You don't need to apply patch all so just apply 2,3,4,5.
> This patches are based on mmotm-12-02 so if you suffered this patches
> from applying your kernel, I can help you. :)
> 
I am very sorry for my lack of responsiveness. It's the last week of the
semester so things have been a bit busy. Nevertheless, I did do some
testing on v3 of the patch last week. Unfortunately, the results weren't
so promising, although this very well could be due to problems with my
test. For both patched and unpatched rsyncs and kernels I did roughly
the following,

  $ rm -Rf $DEST
  $ cat /proc/vmstat > vmstat-pre
  $ time rsync -a $SRC $DEST
  $ cat /proc/vmstat > vmstat-post
  $ time rsync -a $SRC $DEST
  $ cat /proc/vmstat > vmstat-post-warm

Where $DEST and $SRC both reside on local a SATA drive (hdparm reports
read speeds of about 100MByte/sec). I ran this (test.sh) three times on
both a patched kernel (2.6.37-rc3) and an unpatched kernel
(2.6.37-rc3-mm1). The results can be found in the attached tarball.

Judging by the results, something is horribly wrong. The "drop" (patched
rsync) runtimes are generally 3x longer than the "nodrop" (unpatched
rsync) runtimes in the case of the patched kernel. This suggests that
rsync is doing something I did not anticipate.

I'll redo the test tonight with v4 of the patch and will
investigate the source of the performance drop as soon as the
school-related workload subsides.

Cheers,

- Ben



--=-=-=
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=patchv3-benchmark.tar.gz
Content-Transfer-Encoding: base64

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
uVzv6v/LNEDEAEgDAA==
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
