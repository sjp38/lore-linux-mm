Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD3F3C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:10:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91C502064A
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:10:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ZoyMlSr4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91C502064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E4468E0003; Mon, 11 Mar 2019 16:10:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2947F8E0002; Mon, 11 Mar 2019 16:10:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1ABEF8E0003; Mon, 11 Mar 2019 16:10:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id BC55B8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 16:10:49 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id s5so42278wrp.17
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 13:10:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ZKCjSMCXnbl4Pu4JXE4MWbjLrTVkbghT9J2ILGHq6Q8=;
        b=UeNpIeaEw3lk7VnQEQU2mbmnWLWN6XmLPpeumgiLmrUDHMCviC79t8qqlpN2evtMnR
         1ynsv7VVB9m2OpUp9/jZQrrukr/eVQvZzVIKB1mog9XyXx3Skdxb7MacJz0TU2ZKjNuh
         zrhezOcW07S8zhesV7fajq60+d7EQDgCaTjC9+985w0TViv6qXEgQF/JOAmNMwIyoFrR
         j9gyBeQ3rjgIfURZgM5/ZB4nN5g/KwSuWxT4qV+/q8aICJl0bhL13YfUUWz4p11UjIeK
         vKvgvAM+i4g6u2TfM85G1nYLB+GyzRrVDPebV5SNkXVSuYdrGOzqz6OzdNkckVJZjdFJ
         L3Sw==
X-Gm-Message-State: APjAAAW3MgxLc0/Uj1wpd4FOAaxQmbCQvZGxNoLSgeyeKKGzcRkorFrZ
	Re39fi2FOZIqgYFzSjYuWKO0TyC/SA3E8kh5b4W7QTG1mE9GavtIXArUs1pgU2Pt3BPF6HOYK/U
	iYyX0xXK5gNBQJsB77z2VJd5+ruTGLxovtikmSS/5qOIecXhQwTw2/0Gz8AjYaUf5606PcgwZUf
	4IV/2T6D1PV0Uv0ntl8Ig3BlVb7w3jt1rQpDBbcdx/wZqMFYLneNMt1CJfPsqcK+DYsfid8NSuK
	6nVwBW4REaRK3177ioXdeAK/ane3kTAtqBdxz4PRLSOBD18mS+ajd6UcKkAifqam9wZ7557i8zI
	9tnIBTzyh9QbeAofur9ERpQ3Dwzg+Sw9ja1IGpN77d8WcvTBsrfL8kdljtvu6Fasrq+Hl5aR6fE
	/
X-Received: by 2002:a5d:668b:: with SMTP id l11mr20817598wru.116.1552335049293;
        Mon, 11 Mar 2019 13:10:49 -0700 (PDT)
X-Received: by 2002:a5d:668b:: with SMTP id l11mr20817561wru.116.1552335048293;
        Mon, 11 Mar 2019 13:10:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552335048; cv=none;
        d=google.com; s=arc-20160816;
        b=gyIMCtiMXryMLtR15iLOD7u3TZyY7YZwWNCkJwkrUuUfmO81cgycDMkDGQuc4lQifz
         iJGFVTNZOPDI0sN5z3mLkYmhtcgY1qFOKdD+c8c7kbG7jJqswagkUj2GGyr9nTAhw0xz
         z4ViixmyRvh2ktdVYhqjWVyKn7HyfW23PXEeXuzUo2tS7mjpwufD/zlHEDYqg7k8XOhF
         +4Dohtsg1EcNlcq05IZUk3gTQaH7BNw9rRVA4du4iE9tphx4KlQUur+uITLBtcl1q/Oj
         bt7B11Nt/9YuoH2R6jvGkedY4kZ8KZ/hpowSggFMETjGF7sMNB2JwegF7eWzJloYdk6q
         MOaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ZKCjSMCXnbl4Pu4JXE4MWbjLrTVkbghT9J2ILGHq6Q8=;
        b=AyjXtGk+Ib17o4uzF2reVENVrew76Ds/KpweYZuQ5n3DSJHTP2xQOASG2OJvu16M2P
         AkR8SkjpDeK74ko0OS/FzQmXWAEewjpLeZtjf2CTZEdx8Dszsz99PGEe2lkyPUedRMWR
         CYAMi1fh0lgXzRRdA08AoFQtvwGMEJfZ1O5epNEUkCRg8plwYVJH91wjOj2hklaYh/9o
         t21vS73Bexukpktp8EtwQzWyJrWWIFZT/utAAEgoMK52ZAJ0snhGNS/BNyM4+TDs6IcK
         dFZVw18W5qMfMjrTbsXzaSXjLBfig6ifSRQ0eZ0IbSZoPsKq9y9VMoHkiP1HAN0rcEbq
         Hq8A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZoyMlSr4;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f12sor167300wmc.9.2019.03.11.13.10.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 13:10:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZoyMlSr4;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ZKCjSMCXnbl4Pu4JXE4MWbjLrTVkbghT9J2ILGHq6Q8=;
        b=ZoyMlSr4ebBY08p033osdVOmkU3R9VXs9CSVj/pQyFonxmrwtnSc0LmAVDsfbgP55D
         ddEnaeZ6ws19K7QMY4nRzaczDzZkCQCCyshQblMFWRu/p9vnvksfGlqiQpzEWPHfCHAv
         O2QKUZQ7GMZW0nuLBwPK3KFK9befY91P4bUk0zbAfc1mZTDhSKU6nSdb6IQtUIcVtNPs
         sdHDJ1Egdru01rBhc3N8MHLdIOhSc/XihtaTUrpIfYIttNUT91ca27+5fhDDVQZbXno4
         v5hFaJkbB8G0d4TGxibTSjoLPjvodmj+RX42iAMEJHe+K4qc+Nygj0cw9soZ+ous0rok
         fIAw==
X-Google-Smtp-Source: APXvYqyAhHtIn/JyZsUQaWeDQx/1ZnVIq0WJwtHUsqjs8SGHawVn6dVOeO6ND9qSoUIG6lWkjiWgCCAM1fETYT6zmf4=
X-Received: by 2002:a1c:20d3:: with SMTP id g202mr11751wmg.74.1552335047677;
 Mon, 11 Mar 2019 13:10:47 -0700 (PDT)
MIME-Version: 1.0
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190311174320.GC5721@dhcp22.suse.cz> <20190311175800.GA5522@sultan-box.localdomain>
In-Reply-To: <20190311175800.GA5522@sultan-box.localdomain>
From: Suren Baghdasaryan <surenb@google.com>
Date: Mon, 11 Mar 2019 13:10:36 -0700
Message-ID: <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
To: Sultan Alsawaf <sultan@kerneltoast.com>
Cc: Michal Hocko <mhocko@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	=?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, 
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Christian Brauner <christian@brauner.io>, 
	Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, 
	LKML <linux-kernel@vger.kernel.org>, devel@driverdev.osuosl.org, 
	linux-mm <linux-mm@kvack.org>, Tim Murray <timmurray@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Sultan,

On Mon, Mar 11, 2019 at 10:58 AM Sultan Alsawaf <sultan@kerneltoast.com> wrote:
>
> On Mon, Mar 11, 2019 at 06:43:20PM +0100, Michal Hocko wrote:
> > I am sorry but we are not going to maintain two different OOM
> > implementations in the kernel. From a quick look the implementation is
> > quite a hack which is not really suitable for anything but a very
> > specific usecase. E.g. reusing a freed page for a waiting allocation
> > sounds like an interesting idea but it doesn't really work for many
> > reasons. E.g. any NUMA affinity is broken, zone protection doesn't work
> > either. Not to mention how the code hooks into the allocator hot paths.
> > This is simply no no.
> >
> > Last but not least people have worked really hard to provide means (PSI)
> > to do what you need in the userspace.
>
> Hi Michal,
>
> Thanks for the feedback. I had no doubt that this would be vehemently rejected
> on the mailing list, but I wanted feedback/opinions on it and thus sent it as anRFC.

Thanks for the proposal. I think Michal and Joel already answered why
in-kernel LMK will not be accepted and that was one of the reasons the
lowmemorykiller driver was removed in 4.12.

> At best I thought perhaps the mechanisms I've employed might serve as
> inspiration for LMKD improvements in Android, since this hacky OOM killer I've
> devised does work quite well for the very specific usecase it is set out to
> address. The NUMA affinity and zone protection bits are helpful insights too.

The idea seems interesting although I need to think about this a bit
more. Killing processes based on failed page allocation might backfire
during transient spikes in memory usage.
AFAIKT the biggest issue with using this approach in userspace is that
it's not practically implementable without heavy in-kernel support.
How to implement such interaction between kernel and userspace would
be an interesting discussion which I would be happy to participate in.

> I'll take a look at PSI which Joel mentioned as well.
>
> Thanks,
> Sultan Alsawaf

Thanks,
Suren.

