Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD56BC282C2
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 01:02:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8491920873
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 01:02:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8491920873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13E898E00C1; Sun, 10 Feb 2019 20:02:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0EE558E00BF; Sun, 10 Feb 2019 20:02:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF7E58E00C1; Sun, 10 Feb 2019 20:02:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id ADF988E00BF
	for <linux-mm@kvack.org>; Sun, 10 Feb 2019 20:02:50 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id r9so8460516pfb.13
        for <linux-mm@kvack.org>; Sun, 10 Feb 2019 17:02:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=+awOEQ88Z4xa3ENMqaZOrBLL4Gu/0ijb5TV4mVQyg9A=;
        b=E2DwGOvEAlZKWdyXCM8INBO8V88kZOelJ7h+jtPhjNqbdWgBPmQrsPPEtyo+xQ3UDC
         7mP5XeqNuyB81Ifncs0RYVAUjiFBLpEkDkgmGVhCtGfNKlUSAHEj4CaK+Ftx8vbzEAn6
         91qivTODxvY2RkKSg0EZLFXZYmgCQGQUM9gYh9qPF3Wq4QeIz+Spnujne/FgIX2cc6so
         P/xZRhIUby+BI0grE+dHQmGhiYMxE+fTmGS1iXVAO1XbTGfSFatdLgl5sFJYtrBYAWF/
         NjvK2ZSeX+ySOsFsfgrkZIOAhqRHzu8x11h3sPiDxVQjTWrS6lrvuVYRFFthA0tnPSUi
         KN0A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAub5YAiaVJxuk9qLEuvYxy7C8mD2flmz0SYLG6DQcun8ELKz/TTK
	mz4k369QrTDPicvYrSP8iDH6Z+OlJYkWtig3pkvIp0xobtQVTCkUFBqhZ+YiiPf9XMEkkD3GjxY
	eDyrtV5fn34XVRuO15w2KALrDBt4TYjLFLlDlGU13C7CcbXqhtTYgV0jY56/V3IcF/A==
X-Received: by 2002:a63:170c:: with SMTP id x12mr30559441pgl.364.1549846970327;
        Sun, 10 Feb 2019 17:02:50 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYoQ9vaEGsverqVOL0VsZR+Aalm60vTAQrmaDe5vINdgv4VCTDJW9RpjZEhaEBPQT4gyyUn
X-Received: by 2002:a63:170c:: with SMTP id x12mr30559390pgl.364.1549846969358;
        Sun, 10 Feb 2019 17:02:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549846969; cv=none;
        d=google.com; s=arc-20160816;
        b=DyodxpJO4u0Z82ZTfDtleqrXj/ZyT8doDmA8m0liyoep9tORAQOQxZNwVAqFIB2nbt
         tv9nCemG4fsRL2TaH6qrKfVs3ERHFRkZZtMthKSvzJ/Z8tzDHsr37jiiLxMHygjldzAW
         MGSAx86OnXEwmZCt8NA3M2NPhmbnp26jyG70cDBe4xZnzDaGb1TJr0kNxf15GYdvs9E0
         imBXG3C4Lxsyhf0hK41Vy6WfLfJuk76IQ9+ndykxeTiPN8B9N/EM5gr+UGt8JtN7epg2
         zm5mVyBZmZl+7POSaG3BIUF8731vA7Qffb3Kh2vb+09ZJvRfkWNmCZfCtpdix/2JgREr
         NoTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=+awOEQ88Z4xa3ENMqaZOrBLL4Gu/0ijb5TV4mVQyg9A=;
        b=0caaMdJIlyLQnmKhMssytJRg8Gt2TuWk6Npt3pACcSibFNLYlFhC06tQzJL+7HnR9y
         caYiM/+LkBMok0P1jmtZhvoUMDAAPpVGoP87LV8WejC+zGH/m0S0yN6H8zWpo4CO5tpM
         WtvpULevZ4EwqsSRWRtXqCEAgokw8IkZuKUzSVthv0/kpQx3uyBuEJMC0G816wkTIZs6
         9BVsfeORNkfE+IdN+aEQ331cEWkkRa4lfnV6ErgVdD/MrD14PTgfMZPP+mI+N2w/5qIC
         x11seHvnh0MXNbuiT8IMvFLVCVW7eOTN3oRhL20FcnW8d3JY+0g/oAHPDh0UsBbdHDSJ
         KZyA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a8si8587841pff.153.2019.02.10.17.02.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Feb 2019 17:02:49 -0800 (PST)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Feb 2019 17:02:48 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,357,1544515200"; 
   d="scan'208";a="317897442"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.151])
  by fmsmga006.fm.intel.com with ESMTP; 10 Feb 2019 17:02:45 -0800
From: "Huang\, Ying" <ying.huang@intel.com>
To: Andrea Parri <andrea.parri@amarulasolutions.com>
Cc: Hugh Dickins <hughd@google.com>,  Andrew Morton <akpm@linux-foundation.org>,  Daniel Jordan <daniel.m.jordan@oracle.com>,  <dan.carpenter@oracle.com>,  <dave.hansen@linux.intel.com>,  <sfr@canb.auug.org.au>,  <osandov@fb.com>,  <tj@kernel.org>,  <ak@linux.intel.com>,  <linux-mm@kvack.org>,  <kernel-janitors@vger.kernel.org>,  <paulmck@linux.ibm.com>,  <stern@rowland.harvard.edu>,  <peterz@infradead.org>,  <willy@infradead.org>,  <will.deacon@arm.com>
Subject: Re: About swapoff race patch  (was Re: [PATCH] mm, swap: bounds check swap_info accesses to avoid NULL derefs)
References: <20190114222529.43zay6r242ipw5jb@ca-dmjordan1.us.oracle.com>
	<20190115002305.15402-1-daniel.m.jordan@oracle.com>
	<20190129222622.440a6c3af63c57f0aa5c09ca@linux-foundation.org>
	<87tvhpy22q.fsf_-_@yhuang-dev.intel.com>
	<20190131124655.96af1eb7e2f7bb0905527872@linux-foundation.org>
	<alpine.LSU.2.11.1902041257390.4682@eggly.anvils>
	<20190207234244.GA6429@andrea>
Date: Mon, 11 Feb 2019 09:02:45 +0800
In-Reply-To: <20190207234244.GA6429@andrea> (Andrea Parri's message of "Fri, 8
	Feb 2019 01:28:29 +0100")
Message-ID: <87sgwvqgqy.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Parri <andrea.parri@amarulasolutions.com> writes:

> Hi Huang, Ying,
>
> On Mon, Feb 04, 2019 at 01:37:00PM -0800, Hugh Dickins wrote:
>> On Thu, 31 Jan 2019, Andrew Morton wrote:
>> > On Thu, 31 Jan 2019 10:48:29 +0800 "Huang\, Ying" <ying.huang@intel.com> wrote:
>> > > Andrew Morton <akpm@linux-foundation.org> writes:
>> > > > mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch is very
>> > > > stuck so can you please redo this against mainline?
>> > > 
>> > > Allow me to be off topic, this patch has been in mm tree for quite some
>> > > time, what can I do to help this be merged upstream?
>
> [...]
>
>
>> 
>> Wow, yes, it's about a year old.
>> 
>> > 
>> > I have no evidence that it has been reviewed, for a start.  I've asked
>> > Hugh to look at it.
>> 
>> I tried at the weekend.  Usual story: I don't like it at all, the
>> ever-increasing complexity there, but certainly understand the need
>> for that fix, and have not managed to think up anything better -
>> and now I need to switch away, sorry.
>
> FWIW, I do agree with Hugh about "the need for that fix": AFAIU, that
> (mainline) code is naively buggy _and_ "this patch":
>
>   http://lkml.kernel.org/r/20180223060010.954-1-ying.huang@intel.com
>
> "redone on top of mainline" seems both correct and appropriate to me.

Thanks!  Because the patch needs to go through -mm tree, so I will
rebase the patch on top of the head of -mm tree.
>
>> (I was originally horrified by the stop_machine() added in swapon and
>> swapoff, but perhaps I'm remembering a distant past of really stopping
>> the machine: stop_machine() today looked reasonable, something to avoid
>> generally like lru_add_drain_all(), but not as shameful as I thought.)
>
> AFAIC_find_on_LKML, we have three different fixes (at least!): resp.,
>
>   1. refcount(-based),
>   2. RCU,
>   3. stop_machine();
>
> (3) appears to be the less documented/relied-upon/tested among these;
> I'm not aware of definitive reasons forcing us to reject (1) and (2).

Because swapoff() is a really cold path, while page fault handler is a
really hot path.  (3) can minimize the overhead of the hot path.

Best Regards,
Huang, Ying

>   Andrea
>
>
>> 
>> Hugh

