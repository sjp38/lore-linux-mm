Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6FFFC282C2
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 00:28:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61BA421916
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 00:28:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amarulasolutions.com header.i=@amarulasolutions.com header.b="D67VAcZg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61BA421916
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amarulasolutions.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFF128E006C; Thu,  7 Feb 2019 19:28:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAD058E0002; Thu,  7 Feb 2019 19:28:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9C4E8E006C; Thu,  7 Feb 2019 19:28:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7325A8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 19:28:39 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id y129so2583042wmd.1
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 16:28:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=TFpCruOEkYxlPOvEEM4WFb5ey4gGwCCM6JNzhOMWsYE=;
        b=mND0hnwvWUPpUyOAdfOXcWKwbBJcuEq+MEz6QHuxBBcc2qthV0NiX0XywjdX+hzwuB
         aFmhcBXE0yzgfw6ezuP335wlWYmxZvh6ec7+uZ9pXhanot+fTTbt4mLaRIjMfdUeiFaU
         TEn1jcilxO93uZ9/aPMF+aKepIjx7EXWL3H7t/PXGcegAXJinqcRkey+SfUSI+ohh9Rz
         LakELdk2yMHnJPJiSuYAdke3wBIwAAMeXmRezd5VoODgtdOul85XkB4rxxL3V2n9hn0M
         pjYY4BO3eC9yw5J6kNN2cXZBfoEqd065ZQJ6Vmd0UVLvKRnWKhcVA/CDKNDxXwZMV7lL
         lP4w==
X-Gm-Message-State: AHQUAubjVDlx1ViSXyv3OkglK7yAeRo4HLM5xTnHA7qAtIWK35h4vsQl
	iEUtxFatBTJuOognKNK8ZsbAspXmHXv/9uYcX53siJ276UfBhMXtxhpPvSA2lbOXQRXGPdUT4e9
	ywGaUGxrDv6MfKD5LNgALocke+daRzqFklQW6TQiAGf7LYR6E4PN6y5qccL5N0ilLFK5uZDEEUR
	/SR8FexBzog2We6l9y1/notGqr3ieoY9zpGNSNEoK0UOc5o/lLTXIdk5cXMIHZy/cMYIi81VKtr
	ARkSPpzjdJjFUpghsStlM7T4IW5Zw34Niwdkb/fMf4MN69NEWPUww4h/sUFwKSgvoJaspmV3Geq
	//bpVA7E4aQiGSK2LDvO8k5mrnCa7Xz+o+t309/U0y3S64pOWFlPVymhRk/o0NoW3nBnUL/beY1
	O
X-Received: by 2002:adf:8b83:: with SMTP id o3mr14762466wra.81.1549585718791;
        Thu, 07 Feb 2019 16:28:38 -0800 (PST)
X-Received: by 2002:adf:8b83:: with SMTP id o3mr14762434wra.81.1549585717829;
        Thu, 07 Feb 2019 16:28:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549585717; cv=none;
        d=google.com; s=arc-20160816;
        b=brdLKAO9kfRm2LNCic9ZI08pfMZX1UQMJEKEmqejcgWqF6HDI/H19ESkhCBvfakUmv
         wjBW0NxKzpWmYeM3mVszXsyXEJLqA7vPpiy94CqOiRN9sykN/8C1sI0Ais6QMj5gtExX
         /i8T3hjxnglmXSyvnbohRpTiUYHaXO+s34Gw+PwNT1XF6w29vc4ZxBarFvHHAiZ3tsgg
         NdlmXucRUA4mw3gmdtAaqE4VXNCcpzOWd7vuF+6wHrU3uaOs6mbPm/MFE2kVhX5GJzSj
         15wnkpLjxkizNab1GFzcogjGcD5kxxnWDVkZ9jdNXGvq47U7cXxbZuK0k77DyG8lLicc
         ta4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=TFpCruOEkYxlPOvEEM4WFb5ey4gGwCCM6JNzhOMWsYE=;
        b=ba7uQwl1icpXmKg2RVn6uyBBocwG6xVj4GrfYcdmLZWspzEtBzMJxVAXhK4XNgLb3m
         em9snzabVRozaETvNl6eIfogOqOfTFODdDyEdQQGUJLjQkxVx0dDVdsjL2kN3f/i2pJB
         Aj8qNH5e3CIpr9hpk11p3d7AXlC2vtfgWcdc22emY1PgqXCuXNGkD8MKZ+thNcmtBPmb
         Yy7w3XNeR3Dkhxl0qfE9/JlWNtFarBkuxxp9GFIkCDvZd8UCJpFQBKoLisT9fezgLoXt
         8pPe9MW3didvI45CFc4N17Hb6UGh0TEIWWzqXYbR4aO5esOm2CpH0hp1Od5L+Diu3zza
         BzeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amarulasolutions.com header.s=google header.b=D67VAcZg;
       spf=pass (google.com: domain of andrea.parri@amarulasolutions.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andrea.parri@amarulasolutions.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i1sor538160wmb.11.2019.02.07.16.28.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 16:28:37 -0800 (PST)
Received-SPF: pass (google.com: domain of andrea.parri@amarulasolutions.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amarulasolutions.com header.s=google header.b=D67VAcZg;
       spf=pass (google.com: domain of andrea.parri@amarulasolutions.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andrea.parri@amarulasolutions.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amarulasolutions.com; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=TFpCruOEkYxlPOvEEM4WFb5ey4gGwCCM6JNzhOMWsYE=;
        b=D67VAcZg3uDP0lt9Sqg3MIsMeyXF/IH/FyGFwTyCK9FBdMzZcUZ/IEInD3OWp8WxIC
         WEVgcce2X8YCEDWht3MGxN0hhnRiDp/ybXUoyenVwtWaQ8Ej36yQNGKDNTmUnP3XLmo5
         Pf2D+6vx6zZug8M9Bnfd8AMx+hd9KrPLV1IY0=
X-Google-Smtp-Source: AHgI3Ib1IgqbTuJHNdOcNnbDtuMtaOd+O86FOmXBYiUksPi/GJs8dD1XdmK4O4yj6ekfRFBRqwpfDA==
X-Received: by 2002:a1c:6c14:: with SMTP id h20mr521880wmc.78.1549585717124;
        Thu, 07 Feb 2019 16:28:37 -0800 (PST)
Received: from andrea ([89.22.71.151])
        by smtp.gmail.com with ESMTPSA id w16sm464450wrp.1.2019.02.07.16.28.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 16:28:36 -0800 (PST)
Date: Fri, 8 Feb 2019 01:28:29 +0100
From: Andrea Parri <andrea.parri@amarulasolutions.com>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Huang, Ying" <ying.huang@intel.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	dan.carpenter@oracle.com, dave.hansen@linux.intel.com,
	sfr@canb.auug.org.au, osandov@fb.com, tj@kernel.org,
	ak@linux.intel.com, linux-mm@kvack.org,
	kernel-janitors@vger.kernel.org, paulmck@linux.ibm.com,
	stern@rowland.harvard.edu, peterz@infradead.org,
	willy@infradead.org, will.deacon@arm.com
Subject: Re: About swapoff race patch  (was Re: [PATCH] mm, swap: bounds
 check swap_info accesses to avoid NULL derefs)
Message-ID: <20190207234244.GA6429@andrea>
References: <20190114222529.43zay6r242ipw5jb@ca-dmjordan1.us.oracle.com>
 <20190115002305.15402-1-daniel.m.jordan@oracle.com>
 <20190129222622.440a6c3af63c57f0aa5c09ca@linux-foundation.org>
 <87tvhpy22q.fsf_-_@yhuang-dev.intel.com>
 <20190131124655.96af1eb7e2f7bb0905527872@linux-foundation.org>
 <alpine.LSU.2.11.1902041257390.4682@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1902041257390.4682@eggly.anvils>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Huang, Ying,

On Mon, Feb 04, 2019 at 01:37:00PM -0800, Hugh Dickins wrote:
> On Thu, 31 Jan 2019, Andrew Morton wrote:
> > On Thu, 31 Jan 2019 10:48:29 +0800 "Huang\, Ying" <ying.huang@intel.com> wrote:
> > > Andrew Morton <akpm@linux-foundation.org> writes:
> > > > mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch is very
> > > > stuck so can you please redo this against mainline?
> > > 
> > > Allow me to be off topic, this patch has been in mm tree for quite some
> > > time, what can I do to help this be merged upstream?

[...]


> 
> Wow, yes, it's about a year old.
> 
> > 
> > I have no evidence that it has been reviewed, for a start.  I've asked
> > Hugh to look at it.
> 
> I tried at the weekend.  Usual story: I don't like it at all, the
> ever-increasing complexity there, but certainly understand the need
> for that fix, and have not managed to think up anything better -
> and now I need to switch away, sorry.

FWIW, I do agree with Hugh about "the need for that fix": AFAIU, that
(mainline) code is naively buggy _and_ "this patch":

  http://lkml.kernel.org/r/20180223060010.954-1-ying.huang@intel.com

"redone on top of mainline" seems both correct and appropriate to me.


> (I was originally horrified by the stop_machine() added in swapon and
> swapoff, but perhaps I'm remembering a distant past of really stopping
> the machine: stop_machine() today looked reasonable, something to avoid
> generally like lru_add_drain_all(), but not as shameful as I thought.)

AFAIC_find_on_LKML, we have three different fixes (at least!): resp.,

  1. refcount(-based),
  2. RCU,
  3. stop_machine();

(3) appears to be the less documented/relied-upon/tested among these;
I'm not aware of definitive reasons forcing us to reject (1) and (2).

  Andrea


> 
> Hugh

