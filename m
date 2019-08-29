Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D19CC3A5A3
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 15:03:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DC732080F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 15:03:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=arista.com header.i=@arista.com header.b="j6VdB171"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DC732080F
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 922276B0008; Thu, 29 Aug 2019 11:03:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D2806B000E; Thu, 29 Aug 2019 11:03:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7991A6B0010; Thu, 29 Aug 2019 11:03:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0179.hostedemail.com [216.40.44.179])
	by kanga.kvack.org (Postfix) with ESMTP id 520B96B0008
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 11:03:34 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id E59A7180ACEE0
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 15:03:33 +0000 (UTC)
X-FDA: 75875784306.20.coast55_1e17fa7ce934
X-HE-Tag: coast55_1e17fa7ce934
X-Filterd-Recvd-Size: 6407
Received: from mail-io1-f65.google.com (mail-io1-f65.google.com [209.85.166.65])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 15:03:32 +0000 (UTC)
Received: by mail-io1-f65.google.com with SMTP id t6so7529537ios.7
        for <linux-mm@kvack.org>; Thu, 29 Aug 2019 08:03:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=arista.com; s=googlenew;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=9zORjbGk69oJ5dfKY3b1CqJAsKNTapFMC7SK80j7yvM=;
        b=j6VdB1714vSF2YQaaX7iXfHmGH1RD43tZxcwSxpbEk0OT8d23Dt6hUkqGiY4nsTWGs
         jlZ4H8W2hjcIVXH8dbCxGDpgm7G9HWEw8im9053hWj5MUJATS/KTjJ03vCtiAXSjdEDH
         Ja69Qn4LE0sSvAzAx9TjEGiXitRltLabCr56GvucPKS66SMC3FieNAjDizJioIhhZUtK
         u4ixXxOmfpbAiuxqEr20o59W6Bo2xopdUdi6icuPm42FGjclqj/hy4y3VkycolJNPKlC
         /cCy7kqGQAUS+VX80aqwTyGbS9Pd9gaOhReHPGxJwgi9DoGgmIZ4F974fCXEWHLpGuLz
         7spg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=9zORjbGk69oJ5dfKY3b1CqJAsKNTapFMC7SK80j7yvM=;
        b=Uqj342HSjM4Y9pOl2hrYSct5ckS1HH3oUCH3Wdq9B2ESQv7Ca34yW3r6G80xjTzNsP
         aAVv8REzFLJkt7+fiRNlFQb3Xd1AC3PYWFrae4Z3NHZ/Lv0Q4a37xMY3npsHSmwll4Ly
         CA4Y8w8TeCkUOLnGWmOs6JEr/goq72rZV3ZuJFi9NS/BP81PqGEEXQ/Tq/CUsUJPPp5P
         tD/pxr35wjLpWFjhIto/qD1pxV7/p0fqbWH97GFhlUc2y7O4Ab5c0WAkmPWO8BN80NcK
         mMg2NvtbLE0ep1iMkWmLTO8HGoQRFgTzqC0K623a8kL23YCyGYIIvubDtWKk/PxYrnGG
         283Q==
X-Gm-Message-State: APjAAAWTTF5gxVsNrcCQdxy40+VYZgaJN7ncwS8VR5grj3/pVq8JBr7I
	eak6BYlv5FRd8p7gpOix3V63sJKP7T1vkqyFwoPHMg==
X-Google-Smtp-Source: APXvYqx59i598mFm2GBgghGeivK6EaWlSPth0QzEwpZvp75pPj5w+oZSKXR7rqDv3ih969g1f7BxN8U/wVf1ecjdxpU=
X-Received: by 2002:a6b:8b0b:: with SMTP id n11mr5437384iod.101.1567091011925;
 Thu, 29 Aug 2019 08:03:31 -0700 (PDT)
MIME-Version: 1.0
References: <20190826193638.6638-1-echron@arista.com> <20190827071523.GR7538@dhcp22.suse.cz>
 <CAM3twVRZfarAP6k=LLWH0jEJXu8C8WZKgMXCFKBZdRsTVVFrUQ@mail.gmail.com>
 <20190828065955.GB7386@dhcp22.suse.cz> <CAM3twVR_OLffQ1U-SgQOdHxuByLNL5sicfnObimpGpPQ1tJ0FQ@mail.gmail.com>
 <20190829071105.GQ28313@dhcp22.suse.cz> <297cf049-d92e-f13a-1386-403553d86401@i-love.sakura.ne.jp>
 <20190829115608.GD28313@dhcp22.suse.cz>
In-Reply-To: <20190829115608.GD28313@dhcp22.suse.cz>
From: Edward Chron <echron@arista.com>
Date: Thu, 29 Aug 2019 08:03:19 -0700
Message-ID: <CAM3twVSZm69U8Sg+VxQ67DeycHUMC5C3_f2EpND4_LC4UHx7BA@mail.gmail.com>
Subject: Re: [PATCH 00/10] OOM Debug print selection and additional information
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
	Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, 
	Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Ivan Delalande <colona@arista.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 29, 2019 at 4:56 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 29-08-19 19:14:46, Tetsuo Handa wrote:
> > On 2019/08/29 16:11, Michal Hocko wrote:
> > > On Wed 28-08-19 12:46:20, Edward Chron wrote:
> > >> Our belief is if you really think eBPF is the preferred mechanism
> > >> then move OOM reporting to an eBPF.
> > >
> > > I've said that all this additional information has to be dynamically
> > > extensible rather than a part of the core kernel. Whether eBPF is the
> > > suitable tool, I do not know. I haven't explored that. There are other
> > > ways to inject code to the kernel. systemtap/kprobes, kernel modules and
> > > probably others.
> >
> > As for SystemTap, guru mode (an expert mode which disables protection provided
> > by SystemTap; allowing kernel to crash when something went wrong) could be used
> > for holding spinlock. However, as far as I know, holding mutex (or doing any
> > operation that might sleep) from such dynamic hooks is not allowed. Also we will
> > need to export various symbols in order to allow access from such dynamic hooks.
>
> This is the oom path and it should better not use any sleeping locks in
> the first place.
>
> > I'm not familiar with eBPF, but I guess that eBPF is similar.
> >
> > But please be aware that, I REPEAT AGAIN, I don't think neither eBPF nor
> > SystemTap will be suitable for dumping OOM information. OOM situation means
> > that even single page fault event cannot complete, and temporary memory
> > allocation for reading from kernel or writing to files cannot complete.
>
> And I repeat that no such reporting is going to write to files. This is
> an OOM path afterall.
>
> > Therefore, we will need to hold all information in kernel memory (without
> > allocating any memory when OOM event happened). Dynamic hooks could hold
> > a few lines of output, but not all lines we want. The only possible buffer
> > which is preallocated and large enough would be printk()'s buffer. Thus,
> > I believe that we will have to use printk() in order to dump OOM information.
> > At that point,
>
> Yes, this is what I've had in mind.
>

+1: It makes sense to keep the report going to the dmesg to persist.
That is where it has always gone and there is no reason to change.
You can have several OOMs back to back and you'd like to retain the output.
All the information should be kept together in the OOM report.

> >
> >   static bool (*oom_handler)(struct oom_control *oc) = default_oom_killer;
> >
> >   bool out_of_memory(struct oom_control *oc)
> >   {
> >           return oom_handler(oc);
> >   }
> >
> > and let in-tree kernel modules override current OOM killer would be
> > the only practical choice (if we refuse adding many knobs).
>
> Or simply provide a hook with the oom_control to be called to report
> without replacing the whole oom killer behavior. That is not necessary.

For very simple addition, to add a line of output this works.
It would still be nice to address the fact the existing OOM Report prints
all of the user processes or none. It would be nice to add some control
for that. That's what we did.

> --
> Michal Hocko
> SUSE Labs

