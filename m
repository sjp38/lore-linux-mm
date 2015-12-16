Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 8B6186B0038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 13:57:53 -0500 (EST)
Received: by mail-qk0-f169.google.com with SMTP id t125so79517635qkh.3
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 10:57:53 -0800 (PST)
Received: from mail-qk0-x232.google.com (mail-qk0-x232.google.com. [2607:f8b0:400d:c09::232])
        by mx.google.com with ESMTPS id y128si7703844qka.62.2015.12.16.10.57.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Dec 2015 10:57:52 -0800 (PST)
Received: by mail-qk0-x232.google.com with SMTP id k189so79669880qkc.0
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 10:57:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151216181712.GJ29775@pd.tnic>
References: <1450136246-17053-1-git-send-email-toshi.kani@hpe.com>
	<20151216122642.GE29775@pd.tnic>
	<1450280642.29051.76.camel@hpe.com>
	<20151216154916.GF29775@pd.tnic>
	<1450283759.20148.11.camel@hpe.com>
	<20151216174523.GH29775@pd.tnic>
	<CAPcyv4h+n51Z2hskP2+PX44OB47OQwrKcqVr3nrvMzG++qjC+w@mail.gmail.com>
	<20151216181712.GJ29775@pd.tnic>
Date: Wed, 16 Dec 2015 10:57:52 -0800
Message-ID: <CAPcyv4iw=ww3VwgG7XMO7oSX648W89q0czohLZPf=0pL_1p4Dw@mail.gmail.com>
Subject: Re: [PATCH 01/11] resource: Add System RAM resource type
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Toshi Kani <toshi.kani@hpe.com>, Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>

On Wed, Dec 16, 2015 at 10:17 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Wed, Dec 16, 2015 at 09:52:37AM -0800, Dan Williams wrote:
[..]
> Now, imagine you have to do this pretty often. Which is faster: a
> strcmp() or an int comparison...?

Aside from "System RAM" checks I don't think any of these strcmp
usages are in fast paths.

> Even if this cannot be changed easily/in one go, maybe we should at
> least think about starting doing it right so that the strcmp() "fun" is
> phased out gradually...

Sure, but I really don't find use of strcmp() that onerous in slow paths.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
