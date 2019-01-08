Return-Path: <SRS0=RE7g=PQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66B47C43387
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 17:24:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 247C7206A3
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 17:24:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="uRA9FLk3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 247C7206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B06C58E0098; Tue,  8 Jan 2019 12:24:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB7288E0038; Tue,  8 Jan 2019 12:24:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A5C18E0098; Tue,  8 Jan 2019 12:24:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 694078E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 12:24:31 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id x64so2332875ywc.6
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 09:24:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=GL7wYni0pGBI7aKT681Y9wbnQ+0L1OweM8XEjJxZKZE=;
        b=hga1w1Q8zywDeUcnesNKOnRFC2PJn0vtb+oJAo+eYWYtLUZStPjLliRoJ234tm92j4
         jbq+DOeGAOYT2zEr8ziTnN6FnxUtRH9NPX2h+KTIn9eJdQESa9Y5OwAu40l8aP2GUuVF
         388MlGp/klbIj1noWAUF4mNE/cXZ3mtk+VJRBFbKAwFRAwwV6gX9Hq45Vj+4RBtU0xsu
         mXZ4tfOCj+v29XAzH2XZqISQJwD/PDhYSIYDG2/vdmGqctj4XJRmtOiw3PAk3GK6ruX4
         xrFk4B3faaJL90jpDREHvJ2JLmjtvHZjc9oRg6Xh/wVNMpcHuCLCSfwSWuVF5j5eycWC
         95Kw==
X-Gm-Message-State: AJcUukciaazpclIk1KIotrRh4zmAVSzP9CKCc/pPb6agyLXb3Ag8/ej5
	LPpI7Z5la7+MWjSc+lQ9tDZ5A3sqCqLLFirboPTUyinJ8LdrL1MeVnhAWDZpmVUESuKrEGQT00d
	LPZg4+5uvm38oikWC69dflRM89UQeIpXksTc9JgGaFBsbWe8n1eRO6XLK0tjDNj6qB4PJByI26f
	1sfYAQ8tb0hF8at8+lArejfnS3SfJ4WG/i2vVJ56gggmEJR5G7eBfgZ25XqmqYThEqM6EqUzq/j
	9e7JHSWwFYppe0EotklzkWDwPdcWN7jiZJsFK3QJShGijQpTJ4ZQCFutIzV+I43PyGr8JJg+j0A
	eM9CHcnW0zC1eSVAsm1hXmrYrU/ghXXRZqWR2efYZzEVMlPYQd/d0lqs9TWYBW0lmghK29Qf8Oj
	z
X-Received: by 2002:a25:8b09:: with SMTP id i9mr2362072ybl.153.1546968271084;
        Tue, 08 Jan 2019 09:24:31 -0800 (PST)
X-Received: by 2002:a25:8b09:: with SMTP id i9mr2362030ybl.153.1546968270345;
        Tue, 08 Jan 2019 09:24:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546968270; cv=none;
        d=google.com; s=arc-20160816;
        b=k20O0M3lDPDnB3BFxz8TFQ2Gc+23eZNlnJKUN8X3bifReptI9kx09bkX8nektUntLs
         UIqwWvIli+YbXAcE2MRdSO8I9PBUAdaPa14eCgXrC92VE9e6yO/6apz1QrWT4csFrlAm
         Kgj89HxViF7Jd71yU2t43NmhPARJrIgZBNmOQZMlYOnkin+YZIND0MdNubWW5YQJbxYf
         F5V5Im8Jujd77eTujXnLABKdZKnFMf9+85iT5Pb0eRWV/7vfzQTOA8K69+WorKYBwfwj
         LFVhBq83a3ZW4lice5JpLIyJpOtZYXNZYlBFMUR/CnFSvbqvXsbzj9af/3FF+DXTI8CN
         WEsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=GL7wYni0pGBI7aKT681Y9wbnQ+0L1OweM8XEjJxZKZE=;
        b=gWb1SDmruvNvmXoAD9Omx6Eb4kZ4ZouSn33P9lDr8eRf9r3vCqaRkPLE540SK66MGZ
         YLtUnjCVgQoLKMKXDLKHck7qgWOejzUbneE1EtGrfQUfbhrzkYRXZp+PqeUPEek/3EaY
         VW30AMEtfcQuIORTBtAl7HTyHRTAvaw6fSoCO3lz/xZVt8vXRIEBoIzz6DzohdX3r6+A
         iGuL7swWR/Qk8k/VtOyiLvdfuLaYJFPagj+vzpjHYzJw59CGb4ajIgprKchuQjAjqmwp
         o+46JdBJrHtwVoVmoC7GwGmGAufnPQiNQDMFi7AoQjBH2sK7mUYXfTSvfBwWQqwA2yR+
         fT0A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=uRA9FLk3;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u192sor9384816ywf.109.2019.01.08.09.24.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 Jan 2019 09:24:30 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=uRA9FLk3;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=GL7wYni0pGBI7aKT681Y9wbnQ+0L1OweM8XEjJxZKZE=;
        b=uRA9FLk3Ovq2/XZxEHM2QLRek+WzIngFkYCX3CdbfBujIgMjYlURKFJTkCqMKnlg44
         HcTyBZPM9hapyuyfqpFkC7th4LT/bgZ5Z1pLcrMinIB/7XaM91dypigXQH8QNmpDekRr
         l5NYpZKQHiJXK+rRER9tN7yyPJf4hkW13NfxncUnNHR5/B3GePIGssO5C0QNI2ncf/Lu
         COusA3Q5IxD60f5GjhqRawqlo496Ct8CEFgiLoiiDa5U99tvWPew1CYtIU/KCXc3E1fY
         26LJa1uvTNSITIUauX+AUKpWxqWckosoZSoHybTkAWs9UrLKb6fEh+Dx4hdPthl7TqKM
         uleQ==
X-Google-Smtp-Source: ALg8bN7UwPvwt91L36Lu6AysokOtoUleNIpTS0we+Yx31UnfjEVTVhxicsUhuZFn25YXZr40gyokug0U4gubFkJENr4=
X-Received: by 2002:a81:ee07:: with SMTP id l7mr2481282ywm.489.1546968269670;
 Tue, 08 Jan 2019 09:24:29 -0800 (PST)
MIME-Version: 1.0
References: <20190103015638.205424-1-shakeelb@google.com> <20190108145942.GZ31793@dhcp22.suse.cz>
In-Reply-To: <20190108145942.GZ31793@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 8 Jan 2019 09:24:18 -0800
Message-ID:
 <CALvZod6sx6tA2EvnXZ_h=qZu6xtcL14uSMyp-gqxedy8T0L6qg@mail.gmail.com>
Subject: Re: [PATCH] memcg: schedule high reclaim for remote memcgs on high_work
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190108172418.W8DNRXZCSIJQXqqvonXQiTjHrsNr8t-SLWi3V1fOf8Q@z>

On Tue, Jan 8, 2019 at 6:59 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 02-01-19 17:56:38, Shakeel Butt wrote:
> > If a memcg is over high limit, memory reclaim is scheduled to run on
> > return-to-userland. However it is assumed that the memcg is the current
> > process's memcg. With remote memcg charging for kmem or swapping in a
> > page charged to remote memcg, current process can trigger reclaim on
> > remote memcg. So, schduling reclaim on return-to-userland for remote
> > memcgs will ignore the high reclaim altogether. So, punt the high
> > reclaim of remote memcgs to high_work.
>
> Have you seen this happening in real life workloads?

No, just during code review.

> And is this offloading what we really want to do?

That's the question I am brainstorming nowadays. More generally how
memcg-oom-kill should work in the remote memcg charging case.

> I mean it is clearly the current
> task that has triggered the remote charge so why should we offload that
> work to a system? Is there any reason we cannot reclaim on the remote
> memcg from the return-to-userland path?
>

The only reason I did this was the code was much simpler but I see
that the current is charging the given memcg and maybe even
reclaiming, so, why not do the high reclaim as well. I will update the
patch.

thanks,
Shakeel

