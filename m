Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0F1F66B0254
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 01:06:16 -0500 (EST)
Received: by lbblt2 with SMTP id lt2so29198085lbb.3
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 22:06:15 -0800 (PST)
Received: from mail-lf0-x229.google.com (mail-lf0-x229.google.com. [2a00:1450:4010:c07::229])
        by mx.google.com with ESMTPS id z197si7601038lfc.156.2015.11.11.22.06.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 22:06:12 -0800 (PST)
Received: by lffz63 with SMTP id z63so28303119lff.0
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 22:06:12 -0800 (PST)
From: Arkadiusz =?utf-8?q?Mi=C5=9Bkiewicz?= <arekm@maven.pl>
Subject: Re: memory reclaim problems on fs usage
Date: Thu, 12 Nov 2015 07:06:10 +0100
References: <201511102313.36685.arekm@maven.pl> <201511111719.44035.arekm@maven.pl> <201511120719.EBF35970.OtSOHOVFJMFQFL@I-love.SAKURA.ne.jp>
In-Reply-To: <201511120719.EBF35970.OtSOHOVFJMFQFL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201511120706.10739.arekm@maven.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, xfs@oss.sgi.com

On Wednesday 11 of November 2015, Tetsuo Handa wrote:
> Arkadiusz Mi?kiewicz wrote:
> > This patch is against which tree? (tried 4.1, 4.2 and 4.3)
>=20
> Oops. Whitespace-damaged. This patch is for vanilla 4.1.2.
> Reposting with one condition corrected.

Here is log:

http://ixion.pld-linux.org/~arekm/log-mm-1.txt.gz

Uncompresses is 1.4MB, so not posting here.

=2D-=20
Arkadiusz Mi=C5=9Bkiewicz, arekm / ( maven.pl | pld-linux.org )

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
