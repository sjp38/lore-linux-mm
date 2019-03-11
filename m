Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 625F6C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:46:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C79A2064A
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:46:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C79A2064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kerneltoast.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BCAFA8E0003; Mon, 11 Mar 2019 16:46:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B794F8E0002; Mon, 11 Mar 2019 16:46:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A68EB8E0003; Mon, 11 Mar 2019 16:46:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 745C98E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 16:46:33 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id q26so94444otf.19
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 13:46:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=j9c9mo+8DPUzk82qtoerfgEHz5CQacA8eGqE4SQcQfw=;
        b=cv/ANMgkkpZTPoG9tR9XnYoEc367hp3QtRv7u/G/FO4OYMxgfq7h7DUlYgIQOifvI8
         JLUQlbCPE7idCeJzhbLbK8pjGJJwgpIFK4+de/N/tkIpRgcw9trttEZgBLmu+yiN3Q7x
         GPx9VPI7y8Cq9yHr5FjLlL39dTes3Iq/attH2tFH1xIC6f1F/zbCTt7ct+thxzsBo4x/
         o1ZllwKJDeDou472cCewPjHl4faQV4fzguaTPQucebPMAEXNpVf087xU8LfNgX/xtH5F
         /VC6aG1iZ6IigcQGHg/U7Yqg+Mvc33TsTlJ8JC+Lu8eTJms8hR2y2tm4Y2xutm08o39y
         7zbA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Gm-Message-State: APjAAAXLiJJ6qWFRX1AW8rLBVLZ+zX+zNLemSrCqXbp+a2DOVs1PEb1P
	beQzg/0ekdEP5t7ciyKv1lHAFPDWFJnpADgFdwnxR2awDlGA9R+kokwGgwiDsKmP6JLgrXnQ+vd
	dMNFBKMlRvVYuXwe+jPCqXQ3Nm8BOHH2KEzneyyp4AGisNVBGB5iRt47x9XAHQ70YvUV2P2E4Wl
	fE/o4L9zoz1rgR5buPoApRwc0eQvoAHJL466Oc4e4NE+NEFAX/CnjQfoZZD4VdX3Es9n71U3bEz
	DEK8OQLtckdV+90Q6khLa6cqGJJV7+PJ6YiO4hrs+sjnr54BTxxE8KzW7+9IVMuzUasHIvihSsp
	qOyaQyHn8DeJYd7nahqIhTZo50iMBVsUHeK6F/OHsKDXlPVAfe/lQpLqAVGxmO86a89rN3BZ9A=
	=
X-Received: by 2002:a9d:e92:: with SMTP id 18mr22853758otj.134.1552337193051;
        Mon, 11 Mar 2019 13:46:33 -0700 (PDT)
X-Received: by 2002:a9d:e92:: with SMTP id 18mr22853727otj.134.1552337192285;
        Mon, 11 Mar 2019 13:46:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552337192; cv=none;
        d=google.com; s=arc-20160816;
        b=mIG0p3Ke8zrRH2JgGZ/9fk/hI9B83BJnxcbfV0McfIj1+/xca0HgvRTrpub+IQckcp
         ki/e7SLghRj6sfpJwqs2D1bj259y4uQy+xyHEQ+D2e2WOGxKpOuUb01bon/0L1exPt24
         2mcshAxzcT61OZ9dTKgBL7gTFLnyQpRflgOER23MVB/IUrPMGwXQ2+aFy5JRaWd1RXQr
         LNMDf/DtZ2DdNQohthCFmfrSxAzj7C0+Jq6ZDBH2/1ZiGpwD9zPP28mAuqSR6y2dFykQ
         LiGpOTHxdOqvZaRn2csTSQ9Q2dnC8IUh7NSYftu17RatAWtzzqSfYKFwaYAo5gByHu/C
         /Uvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=j9c9mo+8DPUzk82qtoerfgEHz5CQacA8eGqE4SQcQfw=;
        b=AOc2bOP0kVuwMLqpNYjjf9mbN+3cW/PqHMkhP1K5ftlRNKmvHvhH1j1Q+57uF1pKVv
         D8t3MQ9WJOF8wZaEXCUgOWxIe3TM5MUYuzw+2rCm56ooK28oN7XDbxL4RT9kjHeC0PdK
         hL+R5UJ3njoomXSMcMFeuEhBe9jHKPI0ZaBCE5psCp372qKA3mqQQA8B8NOA5Dt6srKq
         3t3LUscZtPNpleiC2ZDtcRphoctl5exe0wL/IK+zpUZTpCxEPx+aUchRdSqSz22A25KD
         R78Zygu1DM163XkqZraxppD/jjDBCw3bm26CZQoV4PXCh3Cj3B/CgrMuyBekhtyEC6yL
         Lxfw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x10sor3918914otg.188.2019.03.11.13.46.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 13:46:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Google-Smtp-Source: APXvYqxQRiH803qpRcDOxJglErXRvHzf9M4g8BMJclGzpIiuZOsHoUODljrh4Klro9fRvKGZfiIk+g==
X-Received: by 2002:a9d:7b4e:: with SMTP id f14mr21423244oto.141.1552337191930;
        Mon, 11 Mar 2019 13:46:31 -0700 (PDT)
Received: from sultan-box.localdomain ([2600:1700:7c70:1680::21])
        by smtp.gmail.com with ESMTPSA id v2sm2621521otk.60.2019.03.11.13.46.29
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Mar 2019 13:46:31 -0700 (PDT)
Date: Mon, 11 Mar 2019 13:46:26 -0700
From: Sultan Alsawaf <sultan@kerneltoast.com>
To: Suren Baghdasaryan <surenb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>,
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
Message-ID: <20190311204626.GA3119@sultan-box.localdomain>
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190311174320.GC5721@dhcp22.suse.cz>
 <20190311175800.GA5522@sultan-box.localdomain>
 <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 01:10:36PM -0700, Suren Baghdasaryan wrote:
> The idea seems interesting although I need to think about this a bit
> more. Killing processes based on failed page allocation might backfire
> during transient spikes in memory usage.

This issue could be alleviated if tasks could be killed and have their pages
reaped faster. Currently, Linux takes a _very_ long time to free a task's memory
after an initial privileged SIGKILL is sent to a task, even with the task's
priority being set to the highest possible (so unwanted scheduler preemption
starving dying tasks of CPU time is not the issue at play here). I've
frequently measured the difference in time between when a SIGKILL is sent for a
task and when free_task() is called for that task to be hundreds of
milliseconds, which is incredibly long. AFAIK, this is a problem that LMKD
suffers from as well, and perhaps any OOM killer implementation in Linux, since
you cannot evaluate effect you've had on memory pressure by killing a process
for at least several tens of milliseconds.

> AFAIKT the biggest issue with using this approach in userspace is that
> it's not practically implementable without heavy in-kernel support.
> How to implement such interaction between kernel and userspace would
> be an interesting discussion which I would be happy to participate in.

You could signal a lightweight userspace process that has maximum scheduler
priority and have it kill the tasks it'd like.

Thanks,
Sultan

