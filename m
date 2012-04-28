Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id CD62D6B0044
	for <linux-mm@kvack.org>; Sat, 28 Apr 2012 09:45:04 -0400 (EDT)
Received: by iajr24 with SMTP id r24so3317992iaj.14
        for <linux-mm@kvack.org>; Sat, 28 Apr 2012 06:45:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+1xoqf1mxbShV2OnLZCjacuyLAUvXwi_70ErOXb=hRTbx9Xcg@mail.gmail.com>
References: <1334903774.5922.35.camel@lappy> <CA+1xoqf1mxbShV2OnLZCjacuyLAUvXwi_70ErOXb=hRTbx9Xcg@mail.gmail.com>
From: Sasha Levin <levinsasha928@gmail.com>
Date: Sat, 28 Apr 2012 15:44:44 +0200
Message-ID: <CA+1xoqeFY0oaj2uj3AkTLUwDbbcKjxPAVZR4gQBUKEVArQeLXg@mail.gmail.com>
Subject: Re: mm: divide by zero in percpu_pagelist_fraction_sysctl_handler()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, mel@csn.ul.ie, cl@linux-foundation.org
Cc: linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Oh, nevermind, I see the problem. I'll send a patch.

On Sat, Apr 28, 2012 at 3:21 PM, Sasha Levin <levinsasha928@gmail.com> wrote:
> Ping? Still see it happening.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
