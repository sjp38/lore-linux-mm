Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79247C5B57D
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 23:48:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DF6D20843
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 23:48:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="REPsxwco"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DF6D20843
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABEC66B0003; Fri,  5 Jul 2019 19:48:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A70198E0003; Fri,  5 Jul 2019 19:48:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95EC98E0001; Fri,  5 Jul 2019 19:48:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 75D1E6B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 19:48:18 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id u84so4265781iod.1
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 16:48:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=wGxDeq81CyX6TH+nRazSmgvOlrD7LrGKRc24O5beNe8=;
        b=Q/1NsCP0DKZFLkXV42BX4MfXl8C3L991DcMCuS76n3d7UWMg9k5/cIAhN8I7Za9AQx
         SjzCorqUAeEBRu3EKnNWIkcX0xfVi+EUqq4XMCssOrTa0bAC5dqqrERafXF/jH5vcjCE
         w9I9ZwkXXjW4rmBK/QhtzDb1YCjc3k9xg0oidKfbVIo6YVfdKlH+OUUN7tGAbY2D6Srw
         yBEE+H6R5DB9JxVYlG4jibHSfBfuuYZj0frRBRIgOMui9XrVlpGPleAk/Pmwb0mKEjC0
         M2aPBcbY68mUJVF/mhYzDCkrEjoDz/R6ipXi/cVmh4hH//5j+CfZvd2hhC0OIa5Gbbh1
         iOHg==
X-Gm-Message-State: APjAAAXofUpjDGxYvX5vdLBfIPm9X7mA/Bcno2qG4QTQPLt/3YtV+sLE
	H9u/GHvx9w8c7eoakWVxvZNqMHnnOSQB1q6DxjR+Fbmivz3MQ/zkR6rSOEQp9SRzFG1SUfwn+aO
	ZsFLN23QUlXpsl3vMMwBew7BBmKPNbIPFugOhO+zQSDrFBj8WOfKAJ/mKmuRg9AEf4A==
X-Received: by 2002:a6b:7b01:: with SMTP id l1mr6709590iop.60.1562370498248;
        Fri, 05 Jul 2019 16:48:18 -0700 (PDT)
X-Received: by 2002:a6b:7b01:: with SMTP id l1mr6709556iop.60.1562370497482;
        Fri, 05 Jul 2019 16:48:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562370497; cv=none;
        d=google.com; s=arc-20160816;
        b=mlmgn5G1PJtYV4izGcpozOqVLeeG+Xb/520U2D+fKt8rvoe9HVaiH4TmQ2dqCC2NDY
         N8iti89VdmcxlE1JSRgRCRTdPpIVPLxCEtdN5snwVrZmZW2pHakmM+eY0+qMNQM1vt2W
         N6OCpd9KJTQRBQN4Tg1+cSpTNrLNuNaO9nrGxMkHdOhbcGD4MaoAgptfQTAaKS0zHXUw
         yexjyWHWIfKguZEhFO29sh+sl8z098q9RwEhVeIxPIpsJDaWIY5cRBHlzQvinvZ0Qskf
         N9Q2v5qBgxJnkklO53bPEjpUnZahhO6/Y1IMrS3q7sglXEeWLGu7SPtGPta8BwD1pITA
         grLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=wGxDeq81CyX6TH+nRazSmgvOlrD7LrGKRc24O5beNe8=;
        b=1Bh2SYBMUZ8eky0/ASJrDwUzvl2JO2l1+rFQ7xcSN/GMYLjEN2o27etqbmp+VNs6Ka
         W/DBJQbocfSA07flZMpmYg1zkPtWEECMSp66yCx455oJcUmV7dhp01p3+sFSzC2V+BQ6
         WwSUaSZVk1beLbk/TLjM/Y0K1/mfjOXqR175gnOPa8YUI+yRNdZ93cFKmczf6w0dZ/D8
         mmIIjUuu0LlHIObfwYlwxu9h4Y1YlWr4YXTRN9eK3GI7hvYkrMqmzMbWvtNFlvEDxUSo
         xJiFCjsoKz6U1QdESooK0V5Rqpkiwg8/fgQ4AsQSkm589YfVJ9njIXe5qDMp5yu6sKkE
         bV0A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=REPsxwco;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g12sor7864028ioh.117.2019.07.05.16.48.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Jul 2019 16:48:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=REPsxwco;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=wGxDeq81CyX6TH+nRazSmgvOlrD7LrGKRc24O5beNe8=;
        b=REPsxwcoiI17ModB/bF/IWm51w4tdRBYyD+zjfsF1cS2iLQWagewHVxK1Wlz4VIjdc
         LO2DShayy8bfpPgl+PmsbbINPPYQi2QN7y7oOxvmdNsGgmQtKl8XqSbCBXER35zU36+y
         1BnYR8MUKGoJLqRfwGJAGAyyvNV8+9jdoSYtdGizVXwmsybzkyisI9wg3i8Eu/uoJ0y3
         QNV5wJjx5vdNq5FhatKgJCpM59VlR+fM57dWG0QEDkT1zy4R94dRKupV9N1yanjlM6aE
         J10OPmLcsTLSUnfy940K8o9bkmwN2qBQX3QNlGVv77Gho/aK0QZTavrGI2Og7ZcORamv
         +Jgw==
X-Google-Smtp-Source: APXvYqxWorwW7ElG3F5kgN09SST6+VfMhnqaW3rKJON2lLL8M5PLynJZO9FzCukiMPTyotu4yFL8fuZOL3uEifU0We8=
X-Received: by 2002:a5d:915a:: with SMTP id y26mr7006370ioq.207.1562370497269;
 Fri, 05 Jul 2019 16:48:17 -0700 (PDT)
MIME-Version: 1.0
References: <1562310330-16074-1-git-send-email-laoar.shao@gmail.com>
 <20190705090902.GF8231@dhcp22.suse.cz> <CALOAHbAw5mmpYJb4KRahsjO-Jd0nx1CE+m0LOkciuL6eJtavzQ@mail.gmail.com>
 <20190705155239.GA18699@chrisdown.name>
In-Reply-To: <20190705155239.GA18699@chrisdown.name>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Sat, 6 Jul 2019 07:47:41 +0800
Message-ID: <CALOAHbBTwas6+rrYAO+OB9R74Ts94T17wojoyOe2+M0CqEbnLw@mail.gmail.com>
Subject: Re: [PATCH] mm, memcg: support memory.{min, low} protection in cgroup v1
To: Chris Down <chris@chrisdown.name>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Shakeel Butt <shakeelb@google.com>, 
	Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 5, 2019 at 11:52 PM Chris Down <chris@chrisdown.name> wrote:
>
> Yafang Shao writes:
> >> Cgroup v1 API is considered frozen with new features added only to v2.
> >
> >The facilities support both cgroup v1 and cgroup v2, and what we need
> >to do is only exposing the interface.
> >If the cgroup v1 API is frozen, it will be a pity.
>
> This might be true in the absolute purest technical sense, but not in a
> practical one. Just exposing the memory protection interface without making it
> comprehend v1's API semantics seems a bad move to me -- for example, how it
> (and things like effective protections) interact without the no internal
> process constraint, and certainly many many more things that nobody has
> realised are not going to work yet.
>

Hmm ?
Would be more specific about the issues without the o internal process
constraint ?
The memcg LRU scan/reclaim works fine on both cgroup v1 and cgroup v2,
so the memcg LRU protection should works fine on both cgroup v1 and
cgroup v2 as well.
IOW, if there're some issues without internal process contraint, then
there must be some issues
in cgroup v1 LRU.

> And to that extent, you're really implicitly asking for a lot of work and
> evaluation to be done on memory protections for an interface which is already
> frozen. I'm quite strongly against that.
>
> >Because the interfaces between cgroup v1 and cgroup v2 are changed too
> >much, which is unacceptable by our customer.
>
> The problem is that you're explicitly requesting to use functionality which
> under the hood relies on that new interface while also requesting to not use
> that new interface at the same time :-)
>

I'm sorry that I can't get your point really.
As I said, the facility is already there.
The memcg LRU is not designed for cgroup v2 only.

> While it may superficially work without it, I'm sceptical that simply adding
> memory.low and memory.min to the v1 hierarchy is going to end up with
> reasonable results under scrutiny, or a coherent system or API.

I have finished some simple stress tests, and the result are fine.
Would you pls give me some suggestion on how to test it if you think
there may be some issues ?

Thanks
Yafang

