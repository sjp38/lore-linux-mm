Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D74FC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 23:52:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28BD620881
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 23:52:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28BD620881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB4DE8E0003; Tue, 29 Jan 2019 18:52:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3D178E0001; Tue, 29 Jan 2019 18:52:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B04EE8E0003; Tue, 29 Jan 2019 18:52:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6A9328E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 18:52:07 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x15so8650848edd.2
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 15:52:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=zAZXbeAZFkL3hRo5dYhHr8sgbI/T1LS1oCJIJB1o9H4=;
        b=uN1WjmZbRxsv+BbZ1/fZwbx0v6/ocFBVf41xzt4TreqGq/iIgWZWjx0FfesQbrWcWu
         5D2vM5MoM1Y8jvFWv/icuYoO9DVnkgJ9OQIDLCIXkTE04PFCfsSrauEs16BLq+rMTC57
         AfBjH+fiW/7Z4qlm/WkSu2IdbYyxwu3HHVzkHEkMR8TdZk2RJ2Uw1TJ7FTB7pp29s51L
         zb8xz3D+3yfy9B4r5lCul6DfVK5Hmksbt6p5Tf13aAhkz44DhxJ4YM3EEvnXZmDZ2NPG
         WWHATwQQcfW3ETacogb1sP5eg4CwIO6UiHax7j07UD/tm0e2GoHXfTHrOFSOX8RMKDFI
         /tjA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUuke5+H0Yip37jl9srS2pOerpvzQCt3aI37zIfSBuGEg0DF4rZKPb
	0B/0DpZFEWugsRaAOra0rE7E6eU9mgvydWqbBqtpWhweahEuZ0b1eWtzVs/5XVBbRpc5AH06Z3T
	yXNrjGG+iRCjsLMAQ3fndDzC+da2ekOvKpiGBy3OZU3KNTVTUaqN38z+H6phJj6Q=
X-Received: by 2002:aa7:c152:: with SMTP id r18mr27787969edp.258.1548805927024;
        Tue, 29 Jan 2019 15:52:07 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4PpfKenjK8x7jLy+5D/0Et6U9VHp/J7gRVfxX3o1vfZPyutyYlzTJAOfVBP9i6HH3lh/3P
X-Received: by 2002:aa7:c152:: with SMTP id r18mr27787868edp.258.1548805924237;
        Tue, 29 Jan 2019 15:52:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548805924; cv=none;
        d=google.com; s=arc-20160816;
        b=NE0RPAENxe60n/yUZo32dcugKYQLGtBWwpuy6n0gvWn9CjG7CnjUbvB4PlqVawquZP
         HeKW4Tb+uvZfHJ/ZlIL4isPn5KXX2V+bnjXDsANc07AX5HKUmoc+gPI0A2HV08Mm9m0V
         Gl//N76h4Zqrhr7n/kG0iTnbI/yBg/fIzNiKf6YfzZxAaZnsKqEO8lkLUAtUD62pAv4/
         IaIPwYGDL0tPp7VHV3+mf1DyZyFTxSjwYSfQPpbCTlOZt6y+U/nwa1DJWBzRC4Ow8kPj
         Q/QjyTRJFgTG0HdGEJRzH7uvaE1CCSwRRJC629YDupnElnsKHI8A1xJV4ArwQ0oEJrmu
         r4rA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=zAZXbeAZFkL3hRo5dYhHr8sgbI/T1LS1oCJIJB1o9H4=;
        b=rXXiXSVhKJeEugHqHJv35LNQ7vyqVxmIyjqmsSWALjLx15JfriZI4UXCzu5cQSFNnO
         I3oy6OM3BAgnk+ifh5zy64KZ9Q9v60DqSczyZ8c6L3QEuJeqMPV2H+Ebl8wtcNjfcING
         0rrRrAy/pzbadFBVNICjutytk7y7OYu0JH2rmz+3nBAfcjWwmRicIa9TH+dRRYxSJ2D1
         V/q0NNdfKXfSx98YfuAKpp0mUTEU6mkNoPOYDDq6CgL3iQTlswWCsRagFrzcwI28cR7d
         hdz/RXWu6VcEai0P/ccrzFGvcblWvmpyQamgFsJKXTmtfthuLUDaK4XfeSGdAfY61kb1
         xDyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i17si133978ejy.203.2019.01.29.15.52.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 15:52:04 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 78AF7AD2F;
	Tue, 29 Jan 2019 23:52:03 +0000 (UTC)
Date: Wed, 30 Jan 2019 00:52:02 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Dominique Martinet <asmadeus@codewreck.org>
cc: Linus Torvalds <torvalds@linux-foundation.org>, 
    Andy Lutomirski <luto@amacapital.net>, Josh Snyder <joshs@netflix.com>, 
    Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, 
    Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
    Greg KH <gregkh@linuxfoundation.org>, 
    Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, 
    Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, 
    Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <20190128000547.GA25155@nautica>
Message-ID: <nycvar.YFH.7.76.1901300050550.6626@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901240009560.6626@cbobk.fhfr.pm> <CAHk-=wg+C65FJHB=Jx1OvuJP4kvpWdw+5G=XOXB6X_KB2XuofA@mail.gmail.com> <20190124002455.GA23181@nautica> <20190124124501.GA18012@nautica> <nycvar.YFH.7.76.1901241523500.6626@cbobk.fhfr.pm>
 <nycvar.YFH.7.76.1901272335040.6626@cbobk.fhfr.pm> <20190128000547.GA25155@nautica>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jan 2019, Dominique Martinet wrote:

> > So, any objections to aproaching it this way?
> 
> I'm not sure why I'm the main recipient of that mail but answering
> because I am -- let's get these patches in through the regular -mm tree
> though

*prod to mm maintainers* (at least for an opinion)

-- 
Jiri Kosina
SUSE Labs

