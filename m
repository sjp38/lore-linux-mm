Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1091F6B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 13:26:56 -0500 (EST)
Received: by mail-qc0-f179.google.com with SMTP id e16so2611874qcx.38
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 10:26:55 -0800 (PST)
Received: from qmta11.emeryville.ca.mail.comcast.net (qmta11.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:211])
        by mx.google.com with ESMTP id pg6si10753526qeb.149.2014.01.16.10.26.54
        for <linux-mm@kvack.org>;
        Thu, 16 Jan 2014 10:26:55 -0800 (PST)
Date: Thu, 16 Jan 2014 12:26:52 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/9] re-shrink 'struct page' when SLUB is on.
In-Reply-To: <52D81214.7070608@sr71.net>
Message-ID: <alpine.DEB.2.10.1401161226170.30036@nuc>
References: <20140103180147.6566F7C1@viggo.jf.intel.com> <20140103141816.20ef2a24c8adffae040e53dc@linux-foundation.org> <20140106043237.GE696@lge.com> <52D05D90.3060809@sr71.net> <20140110153913.844e84755256afd271371493@linux-foundation.org> <52D0854F.5060102@sr71.net>
 <CAOJsxLE-oMpV2G-gxrhyv0Au1tPd87Ow57VD5CWFo41wF8F4Yw@mail.gmail.com> <alpine.DEB.2.10.1401111854580.6036@nuc> <20140113014408.GA25900@lge.com> <52D41F52.5020805@sr71.net> <alpine.DEB.2.10.1401141404190.19618@nuc> <52D5B48D.30006@sr71.net>
 <alpine.DEB.2.10.1401161041160.29778@nuc> <52D81214.7070608@sr71.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 16 Jan 2014, Dave Hansen wrote:

> This was a really tight loop where the caches are really hot, but it did
> show the large 'struct page' winning:
>
> 	http://sr71.net/~dave/intel/slub/slub-perf-20140109.png
>
> As I said in the earlier description, the paravirt code doing interrupt
> disabling was what really hurt the two spinlock cases.

Hrm... Ok. in that case the additional complexity may be justified.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
