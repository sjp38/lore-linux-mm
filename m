Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AA2BC4360F
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 22:59:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E76B62084B
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 22:59:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E76B62084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F6526B0003; Mon,  1 Apr 2019 18:59:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A5976B0005; Mon,  1 Apr 2019 18:59:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2954A6B0007; Mon,  1 Apr 2019 18:59:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 029486B0003
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 18:59:43 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id k185so8498066pga.5
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 15:59:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tHV0DXJdybz6aC7/DiNlnN3KI78Hd4IEOSJlQe1hJgk=;
        b=j59SghO5F26ZPTqp6GfM3CpFnyJXr0yYwAtiEHZt7xcGn+oobRI0XpxvHTnJqe0MtC
         NEHEiy/377bqAfFJc8i3gLhznYircKJBY4aWlfcZ47PAkGzNf6QDQlZDpzSXkyH3I9I0
         t89eslV9yWyPt9twGTk/wAYOJE5jWvd8i7YIKB4R+Hr/aiKqB0uRshTrlK2E55LwAI68
         dxoTgBKXsw5z1gHczmyEQmaRPMneZYonv3E3uYz/ek+3T7dKFElR07vQk9eb6CyIoSkb
         aqvI+xCH/f1sOYFA0mqXoP9cjv3nXd+rOZKC7XYqfuQQ3cR+wADRvMyVzJuE8byg+SyD
         Z4ng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAV6vwHZHk9uz+BifBjn+WkZK1MUKtlXACBgHvQG4a0Sq9E0G3ti
	FnJzQ2Tm9fI1qVhpt8mx+EpqPNpD46lZmW/WKFE731ycEhoO4kyzNGQlKbh9SuM/1xLn7XGfxrI
	SeVLtRko+fN3em4c/rWfRVNul8q57Ja9q6XL5fjdNM86Rcq00lrS1L9MlkxXU8vrgtg==
X-Received: by 2002:a63:f80f:: with SMTP id n15mr63461259pgh.283.1554159582484;
        Mon, 01 Apr 2019 15:59:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjc31JQ1Ygg/NPF7H27zvC+NaVV7ZRAAkxINDAtrnSMl3a1SMmIYQ81qA55Jo53JWwW33V
X-Received: by 2002:a63:f80f:: with SMTP id n15mr63461216pgh.283.1554159581634;
        Mon, 01 Apr 2019 15:59:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554159581; cv=none;
        d=google.com; s=arc-20160816;
        b=u15kwqAb2/u4jMBRTlasUR6lsWKYgGxnRETOdg2d/ZRvAYy/2eAhDhzLN183g2+X6N
         CBlmDGWaaCutw+tqOhKiKm9lSPPbv98XVyecA0JR5MD7B8SvubYd0y8ayArV1ooU/2zm
         wYszOOHbljK9C1IRxjOtruWiIIrNMtE7Xf2jUbNMEmBM/mhwxKaQq3AfU7LoQ6s58mf9
         GnKWxRjyCtZWb4JqHhca3z2Wg5L91C+ZcxJTVqXwFv3iKPAd12VSFVrQq00inORaLF4P
         U15HVPfOKish1Kpy+7ayKH1Uh635I8E3e+3YWWtNHItu7n6glAP4VHHmdVzfOzAldKqV
         uiYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=tHV0DXJdybz6aC7/DiNlnN3KI78Hd4IEOSJlQe1hJgk=;
        b=IhH+/aLlPJ+lZqek7PwWBBEmKH+iqlB3+teGomIVIVUtBTtVjva6/sRnheTEHkKBrP
         Ge0bKbV573zQZ5MY2C9A82KMbm2I1TNAEQMphi9Jx20JxyTiYEmv1/DOZ03de1xXLo0C
         77b8IwytuYsnL+nSXNSmgsFRTqYrUW6BLrBrqGXfMURNTZRKEOJvA/Sn0i4VQo2A9god
         6HVRAqYBC5UnNk+dRXe6X2Y8WPpaK2/2Q+QblbgiugR/NGj5aJSemD5rjkkBAWKRmMxX
         KjAyO/+onqTGt7jiFDFt/Q4N/u1d+X2tdXhKowPh6yJ4pnSOQL1j4IuoVlRjj6DeZCIX
         Jtyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g10si5749726pgq.440.2019.04.01.15.59.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 15:59:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id BEA3D1ACD;
	Mon,  1 Apr 2019 22:59:40 +0000 (UTC)
Date: Mon, 1 Apr 2019 15:59:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Uladzislau Rezki <urezki@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>,
 linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Thomas Garnier
 <thgarnie@google.com>, Oleksiy Avramchenko
 <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>,
 Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>,
 Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 0/1] improve vmap allocation
Message-Id: <20190401155939.66ad1f8ad999fde514002e66@linux-foundation.org>
In-Reply-To: <20190401110347.aby2v6tvqfvhyupf@pc636>
References: <20190321190327.11813-1-urezki@gmail.com>
	<20190321150106.198f70e1e949e2cb8cc06f1c@linux-foundation.org>
	<20190401110347.aby2v6tvqfvhyupf@pc636>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Apr 2019 13:03:47 +0200 Uladzislau Rezki <urezki@gmail.com> wrote:

> Hello, Andrew.
> 
> >
> > It's a lot of new code. I t looks decent and I'll toss it in there for
> > further testing.  Hopefully someone will be able to find the time for a
> > detailed review.
> > 
> I have got some proposals and comments about simplifying the code a bit.
> So i am about to upload the v3 for further review. I see that your commit
> message includes whole details and explanation:
> 
> http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/commit/?id=b6ac5ca4c512094f217a8140edeea17e6621b2ad
> 
> Should i base on and keep it in v3?
> 

It's probably best to do a clean resend at this stage.  I'll take a
look at the deltas and updating changelogs, etc.

