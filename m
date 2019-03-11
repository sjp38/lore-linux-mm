Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C0D1C10F06
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 21:46:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49C222147C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 21:46:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49C222147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kerneltoast.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9EBDC8E0003; Mon, 11 Mar 2019 17:46:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99CF38E0002; Mon, 11 Mar 2019 17:46:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B1928E0003; Mon, 11 Mar 2019 17:46:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4D1F08E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 17:46:58 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id o4so316081pgl.6
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 14:46:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=v68UaAN+XF/lpO/ZYPx+cxL/Cwdo0hNkZMg52MNN2wQ=;
        b=odIcyMyLqZkCWbKliBbCS8BJUNY9/Gn8H0Ed0dYT9NQ+37WBTwnlGbOISg+7jzeLT5
         OsPh/gNQc/QS+PzqLG3dB+CEI7vHGSA3+O2g/gRvBg7hbGo6HaysB8M5lwwOnezIRt/0
         s8IyV7LEN5LnNrDGJGDcTxXDmYHYxOw60PBfGI2E+QVE0PFkZN1VCSjwl5jJpvnqIRNc
         bUXP1+2i57JS+vDAhOK3Qsr2kLEXzHOC1ZecYU4vSRMdphRv5d7BH3vMih77zqKNcTTu
         86McnhOSa2XisBcxUcO2Z6UArD/nBfPVCkLl62fhdxLh2hyie28zXpGYoWaGrJx/gWjL
         bpsw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Gm-Message-State: APjAAAWqL2k0GE8h9ZM9/ijlmfmhZ1rm6jF121wTKIO0UJr3rDAWRoxI
	5d7aXLqp0M+X7wY9m0+uN40hftetYtV09pxoHzGmAwtwDhXEs1eh5ADXSPTuogyJplhR4dBrVkp
	gK/lUweJBTy6W8ZSRRHv8uoV8coP+so8zkaNf3ia7eyizBzjUyOyuixmrC3KY8KNpRjQj7mK99S
	Brr9q9Vzjh/J+ehc/pA92TfHLOH2deQOEFmiZaTifmitSe3WjxDnCDzHPBNxmsMZ2++4c+EPgyb
	EiXnRZ4uQkOUQGxH5c6KfWTdwqmF8aPvsuiEDBMZWztysPDNLoeq04cQ/Rwat6FEdjVKgIL65rM
	hTSt5pzR0zO0+8p5hB6SR1ovCIpnKXC3KXtT/Ocjx4fcFlMRxMaDAVOthZx8OZNnF8QEDSjDyQ=
	=
X-Received: by 2002:a65:65c4:: with SMTP id y4mr23750576pgv.305.1552340817894;
        Mon, 11 Mar 2019 14:46:57 -0700 (PDT)
X-Received: by 2002:a65:65c4:: with SMTP id y4mr23750527pgv.305.1552340816870;
        Mon, 11 Mar 2019 14:46:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552340816; cv=none;
        d=google.com; s=arc-20160816;
        b=IwOYnDkE33POWSo1B+LSebohbLLHxrwiZMSw5bgDSKX6rYgPCnRbnO/seZ6heepTAz
         fMm8Er+5n4CgZoCeg7WJ0qY0RrqrPFc2hRZ4YPpbn4/qYe7OMpRFs0zoXp5IIuw8A5j8
         VvdSdwwzXotFanYZt/uME+kqSD2kfNNlbrUzHiD9lSZvZecmUaGu5/eaas73NEMw3sPC
         8kJLKrgE/WNePhuQtrvROqjRHoqs5952cBDz82hKbW4tJbJU04bnPwHGvx5RnXB5P5hv
         yRQWUPTau232ikTU6RGT8+6sHqMSCf7nwHyDVJ/lNfRAt7Q71baP/uVlHN3GTJNTyabC
         BbRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=v68UaAN+XF/lpO/ZYPx+cxL/Cwdo0hNkZMg52MNN2wQ=;
        b=k/o+4rIMgnfFzcI+yf+dVEuokgfMens3dAPMDsfZ8LUA48WvV6UyVufPcEq9b/iwUd
         gGTN8zlOPpFDf9iyNfYiBn76Or+iD2dP0WH4VdIRam4wnZqJ1Q2Ms8TA16FkbwkRyEGl
         Ga0XhSzbQ34kmYz+Yht/YZDRYZqKuYdtsrhRCMPFaFAGckFOi3EO6LifqarZV7HCgjDJ
         mpISo5qrQOBlYZMFbxN0mYa0vCDBN+q7xJQh4phiVXJASSTGES+EZkF/p8+ZqqHLjd2A
         evlv68ZkEnf3u1DCYmhvVC0Y3yfoP1TeWqjFtweCtBwTS5VxUwtZc/Y91DvVULErp6zy
         3lQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p16sor10406626plo.32.2019.03.11.14.46.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 14:46:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Google-Smtp-Source: APXvYqx/FW5wmQiMfqZNGhD5+OlnFqREHbmUfV07aYsv2Zbx/Ipt5jiexUOqJgCXqXYtCjJeqGLZcg==
X-Received: by 2002:a17:902:9a95:: with SMTP id w21mr35838273plp.118.1552340816219;
        Mon, 11 Mar 2019 14:46:56 -0700 (PDT)
Received: from sultan-box.localdomain (campus-007-074.ucdavis.edu. [168.150.7.74])
        by smtp.gmail.com with ESMTPSA id s18sm9312788pfh.71.2019.03.11.14.46.54
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Mar 2019 14:46:55 -0700 (PDT)
Date: Mon, 11 Mar 2019 14:46:51 -0700
From: Sultan Alsawaf <sultan@kerneltoast.com>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Suren Baghdasaryan <surenb@google.com>,
	Michal Hocko <mhocko@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Christian Brauner <christian@brauner.io>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, devel@driverdev.osuosl.org,
	linux-mm <linux-mm@kvack.org>, Tim Murray <timmurray@google.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190311214651.GA882@sultan-box.localdomain>
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190311174320.GC5721@dhcp22.suse.cz>
 <20190311175800.GA5522@sultan-box.localdomain>
 <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
 <20190311204626.GA3119@sultan-box.localdomain>
 <20190311211125.GA127617@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190311211125.GA127617@google.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 05:11:25PM -0400, Joel Fernandes wrote:
> But the point is that a transient temporary memory spike should not be a
> signal to kill _any_ process.  The reaction to kill shouldn't be so
> spontaneous that unwanted tasks are killed because the system went into
> panic mode. It should be averaged out which I believe is what PSI does.

In my patch from the first email, I implemented the decision to kill a process
at the same time that the existing kernel OOM killer decides to kill a process.
If the kernel's OOM killer were susceptible to killing processes due to
transient memory spikes, then I think there would have been several complaints
about this behavior regardless of which userspace or architecture is in use.
I think the existing OOM killer has this done right.

The decision to kill a process occurs after the page allocator has tried _very_
hard to satisfy a page allocation via alternative means, such as utilizing
compaction, flushing file-backed pages to disk via kswapd, and direct reclaim.
Once all of those means have failed, it is quite reasonable to kill a process to
free memory. Trying to wait out the memory starvation at this point would be
futile.

Thanks,
Sultan

