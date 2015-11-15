Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id B441F6B025B
	for <linux-mm@kvack.org>; Sun, 15 Nov 2015 09:49:39 -0500 (EST)
Received: by lbbcs9 with SMTP id cs9so75730445lbb.1
        for <linux-mm@kvack.org>; Sun, 15 Nov 2015 06:49:39 -0800 (PST)
Received: from mail-lf0-x232.google.com (mail-lf0-x232.google.com. [2a00:1450:4010:c07::232])
        by mx.google.com with ESMTPS id d74si10425053lfd.46.2015.11.15.06.49.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Nov 2015 06:49:37 -0800 (PST)
Received: by lffu14 with SMTP id u14so74369463lff.1
        for <linux-mm@kvack.org>; Sun, 15 Nov 2015 06:49:37 -0800 (PST)
From: Arkadiusz =?utf-8?q?Mi=C5=9Bkiewicz?= <arekm@maven.pl>
Subject: Re: memory reclaim problems on fs usage
Date: Sun, 15 Nov 2015 15:49:35 +0100
References: <201511102313.36685.arekm@maven.pl> <201511151229.23312.arekm@maven.pl> <201511152313.IJI23764.OHVFJFMSFOtOLQ@I-love.SAKURA.ne.jp>
In-Reply-To: <201511152313.IJI23764.OHVFJFMSFOtOLQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201511151549.35299.arekm@maven.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: htejun@gmail.com, cl@linux.com, mhocko@suse.com, linux-mm@kvack.org, xfs@oss.sgi.com

On Sunday 15 of November 2015, Tetsuo Handa wrote:
> Arkadiusz Miskiewicz wrote:
> > On Sunday 15 of November 2015, Tetsuo Handa wrote:
> > > I think that the vmstat statistics now have correct values.
> > >=20
> > > > But are these patches solving the problem or just hiding it?
> > >=20
> > > Excuse me but I can't judge.
> > >=20
> > > If you are interested in monitoring how vmstat statistics are changing
> > > under stalled condition, you can try below patch.
> >=20
> > Here is log with this and all previous patches applied:
> > http://ixion.pld-linux.org/~arekm/log-mm-5.txt.gz
>=20
> Regarding "Node 0 Normal" (min:7104kB low:8880kB high:10656kB),
> all free: values look sane to me. I think that your problem was solved.

Great, thanks!

Will all (or part) of these patches

http://sprunge.us/GYBb
http://sprunge.us/XWUX (after it gets merged)

be pushed to stable@ or are too risky for stable ?

>=20
> $ grep "Normal free:" log-mm-5.txt | cut -b 44- | awk -F' ' ' { print $4 }
> ' | cut -b 6- | sort -g 8608kB
> 8636kB
> 8920kB
> 8920kB
> 8952kB
> 8968kB
> 8980kB
> (...snipped...)
> 215364kB
> 290068kB
> 290428kB
> 291176kB
> 292836kB
> 303992kB
> 306468kB
> 318080kB
> 319548kB
>=20
> $ grep "Normal free:" log-mm-1.txt | cut -b 44- | awk -F' ' ' { print $4 }
> ' | cut -b 6- | sort -g 0kB
> 40kB
> 128kB
> 128kB
> 128kB
> 128kB
> 128kB
> 128kB
> 128kB
> 128kB
> (...snipped...)
> 412kB
> 616kB
> 1268kB
> 1544kB
> 1696kB
> 2756kB
> 2756kB
> 2756kB
> 2756kB
> 2756kB
> 2756kB
> 2756kB


=2D-=20
Arkadiusz Mi=C5=9Bkiewicz, arekm / ( maven.pl | pld-linux.org )

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
