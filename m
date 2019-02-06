Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B422C282CB
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 00:14:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F7132175B
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 00:14:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F7132175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4EDD88E00A3; Tue,  5 Feb 2019 19:14:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4268F8E009C; Tue,  5 Feb 2019 19:14:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F04E8E00A3; Tue,  5 Feb 2019 19:14:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id D89998E009C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 19:14:40 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o17so3382496pgi.14
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 16:14:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=D1N4wxjTxwToc5FsuonoiSOiWLtAEKD+xNG2RxKDvqA=;
        b=uoSxJtJtG/cXsetDZsU+NgZn1ZdZjJDe3FVb9OEcTJxeh5EGC0icqQ4IOS+oWhPI3e
         z//PsqAqQJA9HlXVdb6miGb77IQzqosPNv+lFrH1T+uhKlyEFoqBUx1pvuJQuKaPPzdT
         8sVs8Q4gs0GqleJDh9VAFKYbxALwITM3/QNavzkqCYVRIA9h26av4JAdaLTYfdtoFc71
         r34Gg9Ieh1Dk15vudJaNTJbXnio7psu8F0m8N8NncYFVIU0EDC5uZoc0+i5DBLOQJgpP
         M/5zJXv4goYIu5xFSNNMQdvf52Mtm2dNCgcA1M0EiZUL0jEfMfJWb8kYjQw+5r9v8X0e
         6cVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYt1gd6+UdgRhZnx4SLn8g0gbMthzEt13g3hPs4tOGFP1hN6hQ5
	b+gCMNmTqUyQ5QSl6FvMbyi1C3JaYtkzFtW0P+Bsv4iKFkSujceHWnBalPfGXipKUg1+5QdSRGP
	v+rnmDRGhehGvnU67DHb8IqXvZimfVzCoXG6M24UwiDDyk1W+yo/gGi7new5jslzR1w==
X-Received: by 2002:a17:902:380c:: with SMTP id l12mr7637648plc.326.1549412080517;
        Tue, 05 Feb 2019 16:14:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia3pxu+5lJ2I64av/JFS8CuJXjdHKEtbviBe72CXw0hXKWvMakk3iwcHmy13q7RocTswuiz
X-Received: by 2002:a17:902:380c:: with SMTP id l12mr7637593plc.326.1549412079535;
        Tue, 05 Feb 2019 16:14:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549412079; cv=none;
        d=google.com; s=arc-20160816;
        b=Rhh4WimOrIHuIWQI1tD4eCWDML5+Xly8l+0gbEnAhVHNhZIsSy8c7zwiXFmnHRtqqa
         xyPwrOjG39upULyljcrRtrKnIwBGacKt3e+0apob5L3qJlOe8YSEobh43tYDde1jPEdW
         25wgaowjEfDeRiIeACqCEIFbehSWH+BF2LpCmkBuwtKmrczR1bwy3LJOPPqUA8KUt4mB
         bjGnYylbSCUD8EIGuQE+VncZCMVVqijj6q/UJWPVaQ0uaOAggZmJHpEl+iPlpKOE/lMs
         RHc/4eS1u6RlPRpr1j3H+9cJ5LBfAVQ+ZvGPV/M/4VW46WuC3+26kFOPW2PkDc683Vlu
         0D+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=D1N4wxjTxwToc5FsuonoiSOiWLtAEKD+xNG2RxKDvqA=;
        b=yy110sd/+6nDln8+m6KN34TQ+D8PpFN8xuUCvkb8XaWFPZwMg+CgrDkWB7XNMuAdPE
         abGs8mKvpLpT5mOJl4NE0nT/IO/nLx6YyGpwNw4pynomXfoQ/tRE/dHqmsrljKjAxTRf
         M0zif+b8u+HvVIDz/uqReZvRadrxTjq9OSd+k5z32uI4uVFPAhoPcwyrhcBC21dzGQyk
         lz0h9sSysxbR2kVWZpEt4mCyrTNT5bOZSUKvC1g9Woid8mX83AFeeLRlSRGCD3BfqpOd
         GbW5EpiGs25xtpCa07JjFNn7PUJuyQMzcqKcKHUzMW95HWssFJeKWgYCjVjtIgszCq6N
         Z6+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id b5si4574937pfg.121.2019.02.05.16.14.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 16:14:39 -0800 (PST)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Feb 2019 16:14:38 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,337,1544515200"; 
   d="scan'208";a="122288007"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.151])
  by fmsmga008.fm.intel.com with ESMTP; 05 Feb 2019 16:14:36 -0800
From: "Huang\, Ying" <ying.huang@intel.com>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,  Daniel Jordan <daniel.m.jordan@oracle.com>,  <dan.carpenter@oracle.com>,  <andrea.parri@amarulasolutions.com>,  <dave.hansen@linux.intel.com>,  <sfr@canb.auug.org.au>,  <osandov@fb.com>,  <tj@kernel.org>,  <ak@linux.intel.com>,  <linux-mm@kvack.org>,  <kernel-janitors@vger.kernel.org>,  <paulmck@linux.ibm.com>,  <stern@rowland.harvard.edu>,  <peterz@infradead.org>,  <willy@infradead.org>,  <will.deacon@arm.com>
Subject: Re: About swapoff race patch  (was Re: [PATCH] mm, swap: bounds check swap_info accesses to avoid NULL derefs)
References: <20190114222529.43zay6r242ipw5jb@ca-dmjordan1.us.oracle.com>
	<20190115002305.15402-1-daniel.m.jordan@oracle.com>
	<20190129222622.440a6c3af63c57f0aa5c09ca@linux-foundation.org>
	<87tvhpy22q.fsf_-_@yhuang-dev.intel.com>
	<20190131124655.96af1eb7e2f7bb0905527872@linux-foundation.org>
	<alpine.LSU.2.11.1902041257390.4682@eggly.anvils>
Date: Wed, 06 Feb 2019 08:14:35 +0800
In-Reply-To: <alpine.LSU.2.11.1902041257390.4682@eggly.anvils> (Hugh Dickins's
	message of "Mon, 4 Feb 2019 13:37:00 -0800")
Message-ID: <878sytsrh0.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Hugh,

Hugh Dickins <hughd@google.com> writes:

> On Thu, 31 Jan 2019, Andrew Morton wrote:
>> On Thu, 31 Jan 2019 10:48:29 +0800 "Huang\, Ying" <ying.huang@intel.com> wrote:
>> > Andrew Morton <akpm@linux-foundation.org> writes:
>> > > mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch is very
>> > > stuck so can you please redo this against mainline?
>> > 
>> > Allow me to be off topic, this patch has been in mm tree for quite some
>> > time, what can I do to help this be merged upstream?
>
> Wow, yes, it's about a year old.
>
>> 
>> I have no evidence that it has been reviewed, for a start.  I've asked
>> Hugh to look at it.
>
> I tried at the weekend.  Usual story: I don't like it at all, the
> ever-increasing complexity there, but certainly understand the need
> for that fix, and have not managed to think up anything better -
> and now I need to switch away, sorry.
>
> The multiple dynamically allocated and freed swapper address spaces
> have indeed broken what used to make it safe.  If those imaginary
> address spaces did not have to be virtually contiguous, I'd say
> cache them and reuse them, instead of freeing.  But I don't see
> how to do that as it stands.
>
> find_get_page(swapper_address_space(entry), swp_offset(entry)) has
> become an unsafe construct, where it used to be safe against corrupted
> page tables.  Maybe we don't care so much about crashing on corrupted
> page tables nowadays (I haven't heard recent complaints), and I think
> Huang is correct that lookup_swap_cache() and __read_swap_cache_async()
> happen to be the only instances that need to be guarded against swapoff
> (the others are working with page table locked).
>
> The array of arrays of swapper spaces is all just to get a separate
> lock for separate extents of the swapfile: I wonder whether Matthew has
> anything in mind for that in XArray (I think Peter once got it working
> in radix-tree, but the overhead not so good).
>
> (I was originally horrified by the stop_machine() added in swapon and
> swapoff, but perhaps I'm remembering a distant past of really stopping
> the machine: stop_machine() today looked reasonable, something to avoid
> generally like lru_add_drain_all(), but not as shameful as I thought.)

Thanks a lot for your review and comments!

It appears that you have no strong objection for this patch?  Could I
have your "Acked-by"?

Best Regards,
Huang, Ying

