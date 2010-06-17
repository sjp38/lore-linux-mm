Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2AD5E6B01B2
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:10:43 -0400 (EDT)
Received: by iwn35 with SMTP id 35so2061718iwn.14
        for <linux-mm@kvack.org>; Thu, 17 Jun 2010 07:10:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1006170844300.22997@router.home>
References: <20100617155420.GB2693@localhost.localdomain>
	<alpine.DEB.2.00.1006170844300.22997@router.home>
Date: Thu, 17 Jun 2010 22:10:39 +0800
Message-ID: <AANLkTimYX9PqGJq3dw2n3FZQiIkX0nOKMEOHdYMndHWo@mail.gmail.com>
Subject: Re: [PATCH] Slabinfo: Fix display format
From: wzt wzt <wzt.wzt@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@cs.helsinki.fi, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Thu, Jun 17, 2010 at 9:45 PM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> On Thu, 17 Jun 2010, wzt.wzt@gmail.com wrote:

> This one may break user space tools that have assumptions about the length
> of the field. Or do tools not make that assumption?
>

User space tools usually use sscanf() to extract this field like:
sscanf(buff, "%s %d", name, &num);
If %-27s can break some user space tools that have assumptions about
the length of the field, the orig %-17s can also break it.
The longest name inotify_event_private_data is 26 bytes in 2.6.34-rc2,
the tools still can't extract it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
