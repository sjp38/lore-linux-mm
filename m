Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id A98906B0031
	for <linux-mm@kvack.org>; Sat, 11 Jan 2014 04:26:18 -0500 (EST)
Received: by mail-we0-f182.google.com with SMTP id q59so4858790wes.41
        for <linux-mm@kvack.org>; Sat, 11 Jan 2014 01:26:18 -0800 (PST)
Received: from mail-wg0-x231.google.com (mail-wg0-x231.google.com [2a00:1450:400c:c00::231])
        by mx.google.com with ESMTPS id ys2si5388744wjc.104.2014.01.11.01.26.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 11 Jan 2014 01:26:17 -0800 (PST)
Received: by mail-wg0-f49.google.com with SMTP id a1so2640386wgh.28
        for <linux-mm@kvack.org>; Sat, 11 Jan 2014 01:26:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52D0854F.5060102@sr71.net>
References: <20140103180147.6566F7C1@viggo.jf.intel.com>
	<20140103141816.20ef2a24c8adffae040e53dc@linux-foundation.org>
	<20140106043237.GE696@lge.com>
	<52D05D90.3060809@sr71.net>
	<20140110153913.844e84755256afd271371493@linux-foundation.org>
	<52D0854F.5060102@sr71.net>
Date: Sat, 11 Jan 2014 11:26:16 +0200
Message-ID: <CAOJsxLE-oMpV2G-gxrhyv0Au1tPd87Ow57VD5CWFo41wF8F4Yw@mail.gmail.com>
Subject: Re: [PATCH 0/9] re-shrink 'struct page' when SLUB is on.
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>

On Sat, Jan 11, 2014 at 1:42 AM, Dave Hansen <dave@sr71.net> wrote:
> On 01/10/2014 03:39 PM, Andrew Morton wrote:
>>> I tested 4 cases, all of these on the "cache-cold kfree()" case.  The
>>> first 3 are with vanilla upstream kernel source.  The 4th is patched
>>> with my new slub code (all single-threaded):
>>>
>>>      http://www.sr71.net/~dave/intel/slub/slub-perf-20140109.png
>>
>> So we're converging on the most complex option.  argh.
>
> Yeah, looks that way.

Seems like a reasonable compromise between memory usage and allocation speed.

Christoph?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
