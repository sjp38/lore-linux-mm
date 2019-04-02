Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1D59C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 08:49:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 814EE20645
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 08:49:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TPjN4L0A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 814EE20645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A5AE6B0271; Tue,  2 Apr 2019 04:49:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12ABC6B0272; Tue,  2 Apr 2019 04:49:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F0E596B0273; Tue,  2 Apr 2019 04:49:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 889896B0271
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 04:49:03 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id h6so3277840ljj.10
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 01:49:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=oZpD6xg3efy+1LfQsFiFXVAuAOXY3HlZANyPjrgbP3c=;
        b=V64ByIE2lAKkCx4KkYxzBiL1WB6rApKboV+TvSkRtDlebXJqtF4INxiwRSMSaFeSrp
         Nu5716jGFdPLr0caMHX9Tf+6RjonKuaq1bgQ6mbtH3kLVqQYLEUoucClUGe1lqfjISIP
         YFmBpW+gFiuQiBuZk5owbZD7eQEXhhk76MeJu6OjAGIvyYwNB4qRqA0Zrroh70yZproV
         y5Lz2jv/dKDaScL2D+re3GN3LaseiChgvspa3R1Ve9ZaQOiw0ubk7J9PohfWDjfmaL3M
         OTZ124JDsI2OlgYz9+NTz80bjX2dh6QR02Fj3+x0JuEEbQRRVty/fV4QMybdRfGnmm74
         kSKQ==
X-Gm-Message-State: APjAAAXbRQ6NVSj2IU3V6O4+Egron2dDQEJeBwig0C9NikYrrVoRdDvo
	ZlaEVUx6vUHeZdoRuUHyeSgtjBBhI/VjWLS4+yri+rXF4AlaVmo74sN2QIy96XK3oXcrss01Etq
	F6VxvoiURlHVBUj6uWaioSKGbt+S2V9sjy8Sav/skNyED8XTNcgaPzp5Q7Dl8jPP23A==
X-Received: by 2002:ac2:5396:: with SMTP id g22mr17013514lfh.120.1554194942741;
        Tue, 02 Apr 2019 01:49:02 -0700 (PDT)
X-Received: by 2002:ac2:5396:: with SMTP id g22mr17013467lfh.120.1554194941859;
        Tue, 02 Apr 2019 01:49:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554194941; cv=none;
        d=google.com; s=arc-20160816;
        b=yYUdXQYtLM0SQY6Meb29O7swbif0dYo7pjSobnkGPEJIJzUlTg60Iz7WUgynS4mO0C
         Vu1JGGqvtZOOGkmH1QbLt19y7ijFilYYlX2qOciNrrlOp9T1Z4BVk6irP/eJWC8HYnsH
         kyfXpMliI9q4iVRvc29xXcOgNC4mUWbsMcs2vM9T/D2WtKQ57UbwYMtXZNmKqtzwdE15
         bWtGhXqhN5wLW7HJC4v+DKRXC/mawL7YxY/HmU1AuMAp3tpLKIYN0S4L9+81LkJG4Fgv
         d6upM4yAvyKD232dLPZ4nTSrnEZ1jI14ws8d3xE61YOyD4wsqirYLef84Fwi4csz+v5k
         LO5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=oZpD6xg3efy+1LfQsFiFXVAuAOXY3HlZANyPjrgbP3c=;
        b=sJOXb3RBNRF8XZNGwvzxZGVxJsKAnzmKJbkIb7iS7j1GxQvMTPtMzf8IY4P7mLonW/
         GCsFp9jYy//GpZchEm6r55ulQUBrJgVDQ/tj7CHoutjQWmLaJGnox4J3Vd1CbNI/UXdJ
         IvrG5eJeW8LKu1NzwX5tWuNcQst1j+J9Jr9B45RPe7vV0E6D5LAIruFbyew1MC07hvn5
         TyPzSfmbN5Ax/NKS2G59XX7B/+fx6zWJ/7ftbrd50fx+1fcC6S0buxpQ+46ZW4Sv0xf9
         mmmvY2nSAtc3uXKvW95l9cnV9wMwbBCERU0t/qRPM116m4zgL9FFRW9heEGrIxjMSuFf
         s4SQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TPjN4L0A;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a20sor2863809lfl.60.2019.04.02.01.49.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Apr 2019 01:49:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TPjN4L0A;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=oZpD6xg3efy+1LfQsFiFXVAuAOXY3HlZANyPjrgbP3c=;
        b=TPjN4L0A6RpV2nqcTijTCLDabb47FHE8oG76AMyWauwGNDFjCT4WKj9scUJEyGA54+
         fshX74KK4QPJmvxPRQ1x30VxXM8Qj5t9MJc2OzfsnAISCVzkPNUUFD3ao6MYsHbWh3zr
         b7M7BjVhymjLeW6ciA+hUkzGqrcCBP/3c7vxwDdLmKHeK0T0Ucb2YCiTvxpQGgBFW0IX
         32y8XC1091mK8kB5aGD7QAvk0D2xesUqSMw4UTbq8kPzhhj5/NTkjhHCC8INztAEvqrh
         sF/mOs1A94oDiWAb0Xi31XEzljs1IH/fryOk3xWWsJXmZSBtOFsnP3YyE4q6DVT0eVEl
         C0Xw==
X-Google-Smtp-Source: APXvYqwgOsZRx24mjTnwvSoLCf+v1qUQeKWFfNKmLRSHLhVbBWlkx7FFt2kGR5t/6wIYq498ssGJLA==
X-Received: by 2002:a19:40cc:: with SMTP id n195mr23167947lfa.150.1554194941419;
        Tue, 02 Apr 2019 01:49:01 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id a22sm2369821lfg.37.2019.04.02.01.49.00
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Apr 2019 01:49:00 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Tue, 2 Apr 2019 10:48:53 +0200
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Uladzislau Rezki <urezki@gmail.com>, Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 0/1] improve vmap allocation
Message-ID: <20190402084853.5lyaozljrv6rfcog@pc636>
References: <20190321190327.11813-1-urezki@gmail.com>
 <20190321150106.198f70e1e949e2cb8cc06f1c@linux-foundation.org>
 <20190401110347.aby2v6tvqfvhyupf@pc636>
 <20190401155939.66ad1f8ad999fde514002e66@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190401155939.66ad1f8ad999fde514002e66@linux-foundation.org>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 01, 2019 at 03:59:39PM -0700, Andrew Morton wrote:
> On Mon, 1 Apr 2019 13:03:47 +0200 Uladzislau Rezki <urezki@gmail.com> wrote:
> 
> > Hello, Andrew.
> > 
> > >
> > > It's a lot of new code. I t looks decent and I'll toss it in there for
> > > further testing.  Hopefully someone will be able to find the time for a
> > > detailed review.
> > > 
> > I have got some proposals and comments about simplifying the code a bit.
> > So i am about to upload the v3 for further review. I see that your commit
> > message includes whole details and explanation:
> > 
> > http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/commit/?id=b6ac5ca4c512094f217a8140edeea17e6621b2ad
> > 
> > Should i base on and keep it in v3?
> > 
> 
> It's probably best to do a clean resend at this stage.  I'll take a
> look at the deltas and updating changelogs, etc.
Will resend then.

Thank you.

--
Vlad Rezki

