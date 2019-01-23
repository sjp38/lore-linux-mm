Return-Path: <SRS0=euUm=P7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2294EC282C0
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 20:35:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D662E218A2
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 20:35:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="BY9X9J/4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D662E218A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7287F8E004A; Wed, 23 Jan 2019 15:35:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FEE48E0047; Wed, 23 Jan 2019 15:35:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EE578E004A; Wed, 23 Jan 2019 15:35:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id E547D8E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 15:35:53 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id e8-v6so949371ljg.22
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 12:35:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=SKJLCHAPKT7F2kMasdD5CPgiqsCrm80NhZkTQRdPbiY=;
        b=JtzbkQu/HzXkP0naO1abZrl8VVJ0tIiaDxDcfGyUoJV3BgTpHHrjTo12d2ojkCPRhU
         LJ19/Kj95AiZiZN7TwIvX/RkDNKI8UTuOj0VYRKjBiAl6mB+ml9I7GxdzrJWRg6iBeU4
         O1U88ErCVLgON5BKS7/w/kErTP0vEdTSrymPEaO+U9ZUG7tzF6xei+mVONsrzgNkCOL6
         0Q+BhFcMmO4z/DW3yYV1XkrncY7qfWIGyszg6M82bYXYdAIoFESIQqaco7AosAHAs9Uw
         WF2zwhPYgAckrN3B+H4izVD3iI3dGAbd53jnSdf/Q+RPk5Qhzs+CxMXqCAbjEu8rGTmC
         Nz5A==
X-Gm-Message-State: AJcUukesVYl4tVGKFm8G/Rwa9WobDmOurCVVpVFy8IN/6FtY8uCQ95b7
	cqthRTHmRAFMiN2fCInH1SnEnuYKWO5oHK/cr5ababQpgxjU/jrRugmq5YkYfZ+EEbqVG5SeTim
	vlXiUGp4PCH6rlbLLQbEV3VVLjmZaVUdvj5XgwxvqFmTvSzpf2PCfzKxWz6qYt7VsHWzdgXbjA/
	7lwKE97wL0r6g+bqa5fOkuONqo/3qORjxsWLGyKLkoVzMtcE2o8y56PuI/n2lnPunoyyvAqeihQ
	V/eGAArSBiNJplabwmWALAnlaEFuLHL0qvS9+G3NJTQJg4P9BR1PIc3iQjqmcuvXVixZwxgguMi
	Cy/x/fy5rXwOgFwrigiHfBhWy5FGt/25fFfFFsF5ub2eF/gHmRHgp5BhUi3Y8W0cBerT8c8C6uG
	s
X-Received: by 2002:a2e:9017:: with SMTP id h23-v6mr1716104ljg.71.1548275752992;
        Wed, 23 Jan 2019 12:35:52 -0800 (PST)
X-Received: by 2002:a2e:9017:: with SMTP id h23-v6mr1716077ljg.71.1548275752037;
        Wed, 23 Jan 2019 12:35:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548275752; cv=none;
        d=google.com; s=arc-20160816;
        b=jzMFfhiFY91T7BxamUioOgf0T9jP6Rs7PcHrnlC/1oFLqyEneHhYSfDqE5AEuAYvCq
         yt+B2iLnWRC7VvAMWaOUd2pSIuL2lBpLg6AiNgbHvttLyP5J0X2RhWucL0ZyZzOoIF22
         lq7yiTp27xsLs331TFswJEb4kUGHy6CctJVWcaY/BNxAvj1r1jz+44ecgG9mw3xmHZMF
         OQfcAcJXF3EbCu9pb+4Sc/c0EKJWQ3QLog0FZ9F5s7BHtZPfdYcRub5ltghCkQNIYzD9
         IZQ5IWYAoQj9kE0t0BOQNw3Qgyx2M6LJkRRiT03X3V6YyB1kCrrn9bYs3RtPQasbb8CV
         p5ig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=SKJLCHAPKT7F2kMasdD5CPgiqsCrm80NhZkTQRdPbiY=;
        b=WTs8vV9DVwj/IK2slNTEd6YfVr3gzsvdIyWBe3udunSfTlnOo+LZy0StIbYqeiWrlj
         VV1WFOeErmt3mpjnVGmCh3xeIN9DKshqEM9T3fCHUazItnXSYpO94bKKdf/jMAdTT9z+
         G3Fd+1COiaJc8pHq5f6YUjdlRmhu5vKRA4XDBVvSbEnqSbh1KOsk+Q1jX2yUT2iMhZBJ
         qSOdwp0ed3BxxNMdLPd2D4yQ2tkzUFiM9fSsHhATpJrY8LM538S8fbQdrSIRHIAdcZQ8
         xtVD8EoAkMIwnKSklMDcGyXVuoal9sh2zWt5pmtir+ZQ2MXetZdvNUDWrKANjmQGWrxB
         DNow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b="BY9X9J/4";
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f8-v6sor3112783ljg.0.2019.01.23.12.35.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 Jan 2019 12:35:52 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b="BY9X9J/4";
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=SKJLCHAPKT7F2kMasdD5CPgiqsCrm80NhZkTQRdPbiY=;
        b=BY9X9J/4+qqxYeGyF3R59zxkMjOBG19x6ckQ3lzQ8Ru+lHBQz5Wyx5u058TqaI8R+Z
         qAmOrx5ByYriMlr+YA0ByQJdlVx3veIJOEF+gI83DzB5PUQc/2ZZMGeD81NKhNvS3PWM
         /uSEKiKERYfDI2z3E2tUOXDOKJqrmctffswU4=
X-Google-Smtp-Source: ALg8bN6VVBHfPPkK+mo0a15G+dFy40heShmwqrOzE1R2Ll9qqx1ppbN5viGMVPeYEODbPuppqvcN5Q==
X-Received: by 2002:a2e:9b15:: with SMTP id u21-v6mr2931717lji.29.1548275750967;
        Wed, 23 Jan 2019 12:35:50 -0800 (PST)
Received: from mail-lj1-f173.google.com (mail-lj1-f173.google.com. [209.85.208.173])
        by smtp.gmail.com with ESMTPSA id q3sm635025lff.42.2019.01.23.12.35.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 12:35:49 -0800 (PST)
Received: by mail-lj1-f173.google.com with SMTP id t18-v6so3186856ljd.4
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 12:35:49 -0800 (PST)
X-Received: by 2002:a2e:880a:: with SMTP id x10-v6mr3388044ljh.174.1548275749194;
 Wed, 23 Jan 2019 12:35:49 -0800 (PST)
MIME-Version: 1.0
References: <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com> <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
 <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net> <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com>
 <20190116054613.GA11670@nautica> <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com>
 <nycvar.YFH.7.76.1901161710470.6626@cbobk.fhfr.pm> <CAHk-=wgsnWvSsMfoEYzOq6fpahkHWxF3aSJBbVqywLa34OXnLg@mail.gmail.com>
 <nycvar.YFH.7.76.1901162120000.6626@cbobk.fhfr.pm> <CAHk-=wg+C65FJHB=Jx1OvuJP4kvpWdw+5G=XOXB6X_KB2XuofA@mail.gmail.com>
In-Reply-To: <CAHk-=wg+C65FJHB=Jx1OvuJP4kvpWdw+5G=XOXB6X_KB2XuofA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 24 Jan 2019 09:35:32 +1300
X-Gmail-Original-Message-ID: <CAHk-=wgy+1YT-Rhj5qWb_aCuBADhcq42GDKHB74sqrnOVPKzPg@mail.gmail.com>
Message-ID:
 <CAHk-=wgy+1YT-Rhj5qWb_aCuBADhcq42GDKHB74sqrnOVPKzPg@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Jiri Kosina <jikos@kernel.org>
Cc: Dominique Martinet <asmadeus@codewreck.org>, Andy Lutomirski <luto@amacapital.net>, 
	Josh Snyder <joshs@netflix.com>, Dave Chinner <david@fromorbit.com>, 
	Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, 
	Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190123203532.kJbtBYBKlZz2Q6ES1QW0OhvQykvpswqLXsRxegXQpLo@z>

On Thu, Jan 24, 2019 at 9:27 AM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> I've reverted the 'let's try to just remove the code' part in my tree.
> But I didn't apply the two other patches yet. Any final comments
> before that should happen?

Side note: the inode_permission() addition to can_do_mincore() in that
patch 0002, seems to be questionable. We do

+static inline bool can_do_mincore(struct vm_area_struct *vma)
+{
+       return vma_is_anonymous(vma)
+               || (vma->vm_file && (vma->vm_file->f_mode & FMODE_WRITE))
+               || inode_permission(file_inode(vma->vm_file), MAY_WRITE) == 0;
+}

note how it tests whether vma->vm_file is NULL for the FMODE_WRITE
test, but not for the inode_permission() test.

So either we test unnecessarily in the second line, or we don't
properly test it in the third one.

I think the "test vm_file" thing may be unnecessary, because a
non-anonymous mapping should always have a file pointer and an inode.
But I could  imagine some odd case (vdso mapping, anyone?) that
doesn't have a vm_file, but also isn't anonymous.

Anybody?

Anyway, it's one reason why I didn't actually apply those other two
patches yet. This may be a 5.1 issue..

                   Linus

