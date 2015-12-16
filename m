Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 4E47C6B0038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 12:52:38 -0500 (EST)
Received: by mail-qg0-f52.google.com with SMTP id 21so40455566qgx.1
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 09:52:38 -0800 (PST)
Received: from mail-qk0-x233.google.com (mail-qk0-x233.google.com. [2607:f8b0:400d:c09::233])
        by mx.google.com with ESMTPS id e33si7455157qga.24.2015.12.16.09.52.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Dec 2015 09:52:37 -0800 (PST)
Received: by mail-qk0-x233.google.com with SMTP id p187so76238062qkd.1
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 09:52:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151216174523.GH29775@pd.tnic>
References: <1450136246-17053-1-git-send-email-toshi.kani@hpe.com>
	<20151216122642.GE29775@pd.tnic>
	<1450280642.29051.76.camel@hpe.com>
	<20151216154916.GF29775@pd.tnic>
	<1450283759.20148.11.camel@hpe.com>
	<20151216174523.GH29775@pd.tnic>
Date: Wed, 16 Dec 2015 09:52:37 -0800
Message-ID: <CAPcyv4h+n51Z2hskP2+PX44OB47OQwrKcqVr3nrvMzG++qjC+w@mail.gmail.com>
Subject: Re: [PATCH 01/11] resource: Add System RAM resource type
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Toshi Kani <toshi.kani@hpe.com>, Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>

On Wed, Dec 16, 2015 at 9:45 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Wed, Dec 16, 2015 at 09:35:59AM -0700, Toshi Kani wrote:
>> We do not have enough bits left to cover any potential future use-cases
>> with other strings if we are going to get rid of strcmp() completely.
>
> Look at the examples I gave. I'm talking about having an additional
> identifier which can be a number and not a bit.
>
>>  Since the searches from crash and kexec are one-time thing, and einj
>> is a R&D tool, I think we can leave the strcmp() check for these
>> special cases, and keep the interface flexible with any strings.
>
> I don't think using strings is anywhere close to flexible. If at all, it
> is an odd use case which shouldnt've been allowed in in the first place.
>

It's possible that as far as the resource table is concerned the
resource type might just be "reserved".  It may not be until after a
driver loads that we discover the memory range type.  The identifying
string is driver specific at that point.

All this to say that with strcmp we can search for any custom type .
Otherwise I think we're looking at updating the request_region()
interface to take a type parameter.  That makes strcmp capability more
attractive compared to updating a potentially large number of
request_region() call sites.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
