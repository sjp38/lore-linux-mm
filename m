Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31BD8C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 15:33:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF17D2147C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 15:33:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF17D2147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 78D428E0005; Tue, 12 Mar 2019 11:33:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 713028E0002; Tue, 12 Mar 2019 11:33:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B4E58E0005; Tue, 12 Mar 2019 11:33:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 004658E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 11:33:19 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id t13so1271510edw.13
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 08:33:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=LqRevOFTAX2Ac38MoABsbl45hzYgq9ABXoU3ZKWkRko=;
        b=NRn11uSlbNT1uEEYNZtWqXATCSJlQ1MSl1JfeEenXXyaxLA/G2Y6npP1PBt6oH8H0R
         UsUkwd9O7yhGp76/5QaKcuf31IzePJgvU033k9SdeDALPpGy+QzZvLSl+XSRETWZHPI9
         4wVJ7UoG46U3x0dc9wa0ocUSk3pOUJ3yVzTk3cmRDwgkNsMEx4n+vVckUvBuGzSUnC1J
         +5RzOB7g4sbdgLZI3GOzmIUZBqlqDYZJFRtP6EYqZ/ie538DHxMICY51AJf9vmeq3xvy
         Ec/8guZbIzPl9tENcx2Bt7gjiwz9bN2bPg81RzBI7KTcYT6CW+YVe2UdmUks7efZmqZe
         sThg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXcANq7zC1atH7nyWvCgUz3JQE1H1lfqEidvWVlVM4mfO0SHzSR
	syehnlNWhdfQx1ocDnrHdZ+AQy7H9L8BToef8hqw6XHgfYrZ9W1Anmu4VNCllIi2ZeShnS42UrU
	86ZWiFxR6xQAJ2c2EjL4nMGfCbruGJYy/wyB8fYWyLXa1NEd+v6zq5x5urC8grAo=
X-Received: by 2002:a50:ea87:: with SMTP id d7mr3977173edo.21.1552404798582;
        Tue, 12 Mar 2019 08:33:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5YgKSOG85L2KOLl4A4vOChK0C9cEdBWAckg+p0uGh0Qg8KkjrO3gOxXEhRnOlHPLo2ZXB
X-Received: by 2002:a50:ea87:: with SMTP id d7mr3977120edo.21.1552404797815;
        Tue, 12 Mar 2019 08:33:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552404797; cv=none;
        d=google.com; s=arc-20160816;
        b=XuQKX7lZnx5V2ZL2aPbxmUpTRI41jMKJf3NPuR9MWxEV9DXEp18oF9ERmtHqGSpfyn
         fm+ZxNniswJojTl/0NsaRbhGcHaumy4nPLCu5rgpt56WBvTRAKbu/71IRUPAaTivACi2
         9M9I4ljz0uZ4o0AC3aUCrZ34t3Uu5ByjS4wf7OTqziX+YkgmrC1aOaCzikH3nf3iz/wJ
         rroHq9GYE4eL0kC/K0XsT0izMNG5+FCrvHdL3FUc1fGInkhmgx3lUS3md4gulnuFavPn
         tATmqanSTvsXP3d72WxQq0E7Se6JFsHJuk+HAsQB/D5+y7FADHrvwjXsvjtLEACKYpTl
         6T5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=LqRevOFTAX2Ac38MoABsbl45hzYgq9ABXoU3ZKWkRko=;
        b=ZJubq2YbhSFPMSHtvCbQ0TjcNjMqY82geWj+vtH3zswn/y4sWhGDDp66E7Sv9v4CFb
         rebPtmwYIwzXeBUsmmhowDI9dOJIhbuqFldxaP6JlpDA6CMC7VHxXHG5SE4+7JIZuvRZ
         FnyEmafHH3ZFDpwyvKh6uKRYlKIRcacewZRkMATMBTd9bEkt+e/zRMnW5KUqDcv2XBOd
         lwKKnyZxyRP+jvOHmdheodO9sLSozg633aYcQFyIVrIpszInrD5h7rqrONZ3+uGu+wbQ
         7ymbSNxWPlWev1Id3bosqtHrzRksyvPhQzcFHugyChrDhqZu6WKTVkGRWgDFKzuSfbhw
         AWqg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z13si1987635edh.384.2019.03.12.08.33.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 08:33:17 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 35CC6B69E;
	Tue, 12 Mar 2019 15:33:17 +0000 (UTC)
Date: Tue, 12 Mar 2019 16:33:15 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Suren Baghdasaryan <surenb@google.com>,
	Sultan Alsawaf <sultan@kerneltoast.com>,
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
Message-ID: <20190312153315.GV5721@dhcp22.suse.cz>
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190311174320.GC5721@dhcp22.suse.cz>
 <20190311175800.GA5522@sultan-box.localdomain>
 <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
 <20190311204626.GA3119@sultan-box.localdomain>
 <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
 <20190312080532.GE5721@dhcp22.suse.cz>
 <20190312152541.GI19508@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190312152541.GI19508@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 12-03-19 08:25:41, Matthew Wilcox wrote:
> On Tue, Mar 12, 2019 at 09:05:32AM +0100, Michal Hocko wrote:
> > On Mon 11-03-19 15:15:35, Suren Baghdasaryan wrote:
> > > Yeah, killing speed is a well-known problem which we are considering
> > > in LMKD. For example the recent LMKD change to assign process being
> > > killed to a cpuset cgroup containing big cores cuts the kill time
> > > considerably. This is not ideal and we are thinking about better ways
> > > to expedite the cleanup process.
> > 
> > If you design is relies on the speed of killing then it is fundamentally
> > flawed AFAICT. You cannot assume anything about how quickly a task dies.
> > It might be blocked in an uninterruptible sleep or performin an
> > operation which takes some time. Sure, oom_reaper might help here but
> > still.
> 
> Many UNINTERRUPTIBLE sleeps can be converted to KILLABLE sleeps.  It just
> needs someone to do the work.

They can and should as much as possible. No question about that. But not
all of them can and that is why nobody should be relying on that. That
is the whole point of having the oom_reaper and async oom victim tear
down.

-- 
Michal Hocko
SUSE Labs

