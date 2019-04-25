Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF33EC43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 22:31:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B69D920717
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 22:31:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OIfmquUp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B69D920717
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E56D26B0005; Thu, 25 Apr 2019 18:31:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E05A36B0006; Thu, 25 Apr 2019 18:31:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF55D6B0007; Thu, 25 Apr 2019 18:31:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 687566B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 18:31:33 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id u20so131231lfg.6
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 15:31:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=qtWSEYNNrSPPxdj3tPWrigqz3Ik0xqljYrwcUmqLm5M=;
        b=VDAAPoPL2k9J3bsKCtBW6Mi34UAWeyMFfiM/kYLJMhZJBtanvA2+Y01gw5Dqn5Bz6a
         430jV1/4G6KBuywvtssx0Pxu8/PK6KmmyfN1cWMM9Lx2D+bLXLf7mcwV7c3ffvmHAezO
         u9UbrH7ws7jkvk6ZA8Mm+4tT3TtmFYSPdeejH2dPZMWBHYP/7F/jxveeJ2smwERtJnME
         i5iQ2bFfQNgQ5w0/KrmeFUREicm0hlC4Ykt+ZMWkDwcgBXPIdf28A8qdfloeFrw9gL9K
         i1Utt6/5Vwyzvtdx8nZ1mJVbbkWM5RGIwtfKweOTZ+FYfIU8Cp3MUQ4uiabYiJN2Qf1/
         r48Q==
X-Gm-Message-State: APjAAAVCpXITE4xq/WlcXIXjpaUQB//9KaQJN4Fju9xPj5Uc0dlhEFHa
	fso80n7zR/shBjKGewAxNtqo3StDF2zM9uspCbxRm1If5hk1MaHBXrfJjYPqo70e0LtzNM9LO3i
	dWxCJlQVl48xIqW76bUjl+Llr2VqYMlYbT9qKFvuDyz9ZD3hdyxIfo652X+T81AP41A==
X-Received: by 2002:ac2:5487:: with SMTP id t7mr23974993lfk.41.1556231492502;
        Thu, 25 Apr 2019 15:31:32 -0700 (PDT)
X-Received: by 2002:ac2:5487:: with SMTP id t7mr23974963lfk.41.1556231491695;
        Thu, 25 Apr 2019 15:31:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556231491; cv=none;
        d=google.com; s=arc-20160816;
        b=lLGwsCJ3xwRkYcHwUxW0LYvJ7/BaBMMK2OyqUK8oHN/+aRWRdrPyNALkOerPZig+yY
         vait/dxOeFfpvU94mL49UJzCcp6Nn0LcNhx2KdMpKZOOdCbfzt3+KZQuHXdYsgOeMJ0a
         qq8/UgE30YwMwDUQ3262mBs9UdOsxla5by5hlYLlMXcQQumJ/e68c0lVKa6AoC6WsOnD
         vozoZRyvLuqxf9N2VTLJpUyCKFFhCy2JN/IiikNRe5QvqPd5/gXQOKtwv8+tpbhrYHre
         YaB/7AFsk5phLeY9UezCDSCno4mA0vxBvRVT74JfiAEZeMRIGvWSZnGjDYg/mpaGa7NE
         aanw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=qtWSEYNNrSPPxdj3tPWrigqz3Ik0xqljYrwcUmqLm5M=;
        b=naEMWwwWAQzkoYQP+VzFmyg0yMxdBJC+kSdKxGglY3+XkviIinN5icbFwJsTnyNPnl
         m0LxOvqOYfD0O907B+pwd/Uh8RfF2gOmJAF6+beUoyiG995GQVkkXCe/GRs9MgRzPruI
         l3mmeteBt+0SnfMS2ivBmvNRWDPGiS0sXyffWmOsg6D+e8hf+BV7sgggozUJDde/4Qij
         Yk/2FeN/yWvqWw9r7h4jmnPUunOIYzxaN1YIUi1FlURUlV0cDzDlGnc37f1CInTqbLew
         YdTrzaqGiK1LgBTkqGqrA+Udfs7BbwkIeEHgdNuZwRp30YugJ7cD3b2wEGc5DisaWDyI
         WloQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OIfmquUp;
       spf=pass (google.com: domain of alexei.starovoitov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexei.starovoitov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i12sor3906258lfc.57.2019.04.25.15.31.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 15:31:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexei.starovoitov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OIfmquUp;
       spf=pass (google.com: domain of alexei.starovoitov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexei.starovoitov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qtWSEYNNrSPPxdj3tPWrigqz3Ik0xqljYrwcUmqLm5M=;
        b=OIfmquUpjngb8hiS0nhppG+bleHhRJAALAHqlcTb0834v2IC4dEntvxt94DLdKLnMx
         T6oCm+GjkIk+H1a1PG/AdFE6V+TMOVPBqrclbyEvECyr6YjeV7rmlbgzQPF8vmu42lKk
         p31lWirca9NACo8YAbsi55XrYB7xgjfPePVQejCB2b2QNVFJpNOST5IFrRxRaEW7Ij6D
         Pn5DiibfNI/cSIGGzK87CFFZ4iAcVY2wqIeRpl4U0W2kkplZRhsdTkYaWiH15bTbmahv
         /GGyJB1KkUVXUPHDEKFC2FHcyCCPzL6/L60jnO5pmFbE1YPh8H0stoHWnYXmJiTUFnIk
         qf1A==
X-Google-Smtp-Source: APXvYqwtCV6pv+2SFmUogEOHDhn6HFnoDWZFz6Pm6Pj98CMNtDvgTZNxM5jYOjpKnVs5adcR5hz6qA2vPGzZDQR+l2k=
X-Received: by 2002:ac2:52a8:: with SMTP id r8mr22477652lfm.160.1556231491326;
 Thu, 25 Apr 2019 15:31:31 -0700 (PDT)
MIME-Version: 1.0
References: <20190207072421.GA9120@rapoport-lnx> <CA+VK+GOpjXQ2-CLZt6zrW6m-=WpWpvcrXGSJ-723tRDMeAeHmg@mail.gmail.com>
 <CAPM31RKpR0EZoeXZMXciTxvjBEeu3Jf3ks4Dn9gERxXghoB67w@mail.gmail.com>
 <CA+VK+GOOv4Vpfv+yMwHGwyf_a5tvcY9_0naGR=LgzxTFbDkBnQ@mail.gmail.com>
 <1556229406.24945.10.camel@HansenPartnership.com> <CAPM31R+Wd=2ZMJmg3dZ37xnzHrsnMP6CYZrV+evqNY4Vb6Paqw@mail.gmail.com>
In-Reply-To: <CAPM31R+Wd=2ZMJmg3dZ37xnzHrsnMP6CYZrV+evqNY4Vb6Paqw@mail.gmail.com>
From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Thu, 25 Apr 2019 15:31:19 -0700
Message-ID: <CAADnVQLJqRm=TR7cY8XKYBo63LsJk=bqvn=es3v+2SBa_8zofg@mail.gmail.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Address space isolation inside the kernel
To: Paul Turner <pjt@google.com>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, linux-mm <linux-mm@kvack.org>, 
	lsf-pc@lists.linux-foundation.org, Mike Rapoport <rppt@linux.ibm.com>, 
	Jonathan Adams <jwadams@google.com>, Daniel Borkmann <daniel@iogearbox.net>, Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000129, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 3:27 PM Paul Turner via Lsf-pc
<lsf-pc@lists.linux-foundation.org> wrote:
>
> On Thu, Apr 25, 2019 at 2:56 PM James Bottomley <
> James.Bottomley@hansenpartnership.com> wrote:
>
> > On Thu, 2019-04-25 at 13:47 -0700, Jonathan Adams wrote:
> > > It looks like the MM track isn't full, and I think this topic is an
> > > important thing to discuss.
> >
> > Mike just posted the RFC patches for this using a ROP gadget preventor
> > as a demo:
> >
> >
> > https://lore.kernel.org/linux-mm/1556228754-12996-1-git-send-email-rppt@linux.ibm.com
> >
> > but, unfortunately, he won't be at LSF/MM.
> >
> > James
> >
>
> Mike's proposal is quite different, and targeted at restricting ROP
> execution.
> The work proposed by Jonathan is aimed to transparently restrict
> speculative execution to provide generic mitigation against Spectre-V1
> gadgets (and similar) and potentially eliminate the current need for for
> page table switches under most syscalls due to Meltdown.

sounds very interesting.
"v1 gadgets" would include unpriv bpf code too?

