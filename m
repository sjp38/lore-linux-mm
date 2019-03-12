Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B314C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 16:37:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9F9F206DF
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 16:37:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9F9F206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kerneltoast.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 734B58E0003; Tue, 12 Mar 2019 12:37:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E46D8E0002; Tue, 12 Mar 2019 12:37:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5AB388E0003; Tue, 12 Mar 2019 12:37:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 212938E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 12:37:49 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id f125so1365994oib.4
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 09:37:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=NpM11hIB0n3yQhJ/sBrftpwbwYTEMvFewCfyZrELSOY=;
        b=JO+0Ztb9YsBK2JNttYqSFgIgaVxVuAHaOT9k+DwyTTaUzpMIHPt4uxtSowRAyfuJSW
         XYjPBwGTjqzu/MissahXe0qaOvwVG8bzr4cG5WvSR73Rea1JCzBdfG9zEi2+VL+rDVn3
         LCdy62jpDtO+vNntdih+j1ZO6vEtnXzuGRtUjxyxHJpJm8QSRQfnt2ZqFw5JZprEj+y7
         0QglgArv9w306O9liD3hYRtFYx/srx03blT3E98K/7SgiNirZWwnZNr0kGj0tYawD+NR
         A2WzrS4COba+8X+Xvqp1McUv5QVqq9z9IiTMxKrLMMFG3K2mjUnPorC4DIf6gSdrPnKd
         Gtag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Gm-Message-State: APjAAAWwcLNr7kLr5TcUsRDnfyyv2sq76BDYJLSXcDSO3wlvtEnQqxIG
	XeSL4DALD7tvQZji9elrwZccfUeh1yeHoWWeJAbcFYl0SnROXpEOgfAx9LITLckplTD07Ku4gjU
	q9BYw6WzMzyJ/OMFLEVAwDFTyNL4ZWcOy4zIPzim+Q1ZiKTlvmaWa8J0aSCbFi34=
X-Received: by 2002:aca:538f:: with SMTP id h137mr2317888oib.54.1552408668710;
        Tue, 12 Mar 2019 09:37:48 -0700 (PDT)
X-Received: by 2002:aca:538f:: with SMTP id h137mr2317850oib.54.1552408667863;
        Tue, 12 Mar 2019 09:37:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552408667; cv=none;
        d=google.com; s=arc-20160816;
        b=j3YsC+pL72Mj/u/9ca2gGlbx8oWP+l/rgj29lFgAQvlSwa8qtZ/Q0PCVMBr3Y9miSV
         AyF1r+L4gKqdEbx81aku1Z7t7t6TH5wiK/gTJj/s1c9IUfKEy/qxjYVYvHzwCkUwDyDj
         G81lqYcYZxgSIjYFB9t0+7hydganqoCaUGA11EIA5a6jgR6xInKcguBIT1ebU40cUdUa
         /n3TpQA38RTPnJ50m34keRLOEGbfOioM7kEgG18Yu1IGa5gBsk91mrbqw26trf1gn/wn
         /mIdvBjuV2+DNilL5IuBDdTrqYwT+3NQ825cY1lcUWqs+b3NGJeiJ9S3vStcd8zCc4jl
         rB1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=NpM11hIB0n3yQhJ/sBrftpwbwYTEMvFewCfyZrELSOY=;
        b=T8LMBONY25wHS4Qe+scBmbzZgkivi8J4zBMi5+2eINZ1hZVaqka0P1QIN19m1BxPZm
         4qScph85YEDjf1/i8Lm0YqSFR2Sl0ya0XPxmVC82LmySZZw8/dMzaPNb7dnt40HKHa0p
         rT4VOeDdQn9m6xqElPhRUspRdbCD+222Zb9pb4p2mnB62pIigD39BxO685xCqmNyjOKV
         S4AikJgMWMC64E4xpgwkvoyEWvdn1z8rbLgIePDeoEjt/t8K30MdMyrQpiHQO+AHXNbj
         9s38HqX/18QDUikVEzanDqe8IoQExOOIqVqAI1OWNf/Absj/1z84IELlsx+mUXUkJUcx
         JK4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 35sor4847758otj.185.2019.03.12.09.37.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 09:37:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Google-Smtp-Source: APXvYqwfZPbiQHE8MnOV1ufVTRg1Zl49w8DhEYFFealjY7DbjEoz7zfH9VFfZWBjcFLOm7HAbUx4/A==
X-Received: by 2002:a9d:76d4:: with SMTP id p20mr25164261otl.11.1552408667449;
        Tue, 12 Mar 2019 09:37:47 -0700 (PDT)
Received: from sultan-box.localdomain ([107.193.118.89])
        by smtp.gmail.com with ESMTPSA id 97sm4321579otn.39.2019.03.12.09.37.45
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Mar 2019 09:37:46 -0700 (PDT)
Date: Tue, 12 Mar 2019 09:37:41 -0700
From: Sultan Alsawaf <sultan@kerneltoast.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Suren Baghdasaryan <surenb@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Christian Brauner <christian@brauner.io>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, devel@driverdev.osuosl.org,
	linux-mm <linux-mm@kvack.org>, Tim Murray <timmurray@google.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190312163741.GA2762@sultan-box.localdomain>
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190311174320.GC5721@dhcp22.suse.cz>
 <20190311175800.GA5522@sultan-box.localdomain>
 <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
 <20190311204626.GA3119@sultan-box.localdomain>
 <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
 <20190312080532.GE5721@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190312080532.GE5721@dhcp22.suse.cz>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 09:05:32AM +0100, Michal Hocko wrote:
> The only way to control the OOM behavior pro-actively is to throttle
> allocation speed. We have memcg high limit for that purpose. Along with
> PSI, I can imagine a reasonably working user space early oom
> notifications and reasonable acting upon that.

The issue with pro-active memory management that prompted me to create this was
poor memory utilization. All of the alternative means of reclaiming pages in the
page allocator's slow path turn out to be very useful for maximizing memory
utilization, which is something that we would have to forgo by relying on a
purely pro-active solution. I have not had a chance to look at PSI yet, but
unless a PSI-enabled solution allows allocations to reach the same point as when
the OOM killer is invoked (which is contradictory to what it sets out to do),
then it cannot take advantage of all of the alternative memory-reclaim means
employed in the slowpath, and will result in killing a process before it is
_really_ necessary.

> If you design is relies on the speed of killing then it is fundamentally
> flawed AFAICT. You cannot assume anything about how quickly a task dies.
> It might be blocked in an uninterruptible sleep or performin an
> operation which takes some time. Sure, oom_reaper might help here but
> still.

In theory we could instantly zap any process that is not trapped in the kernel
at the time that the OOM killer is invoked without any consequences though, no?

Thanks,
Sultan

