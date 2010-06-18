Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 17FC76B01AC
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 02:09:20 -0400 (EDT)
Message-ID: <4C1B0D8C.1030906@cs.helsinki.fi>
Date: Fri, 18 Jun 2010 09:09:16 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] Slabinfo: Fix display format
References: <20100617155420.GB2693@localhost.localdomain>	<alpine.DEB.2.00.1006170844300.22997@router.home> <AANLkTimYX9PqGJq3dw2n3FZQiIkX0nOKMEOHdYMndHWo@mail.gmail.com>
In-Reply-To: <AANLkTimYX9PqGJq3dw2n3FZQiIkX0nOKMEOHdYMndHWo@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: wzt wzt <wzt.wzt@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On 6/17/10 5:10 PM, wzt wzt wrote:
> On Thu, Jun 17, 2010 at 9:45 PM, Christoph Lameter
> <cl@linux-foundation.org>  wrote:
>> On Thu, 17 Jun 2010, wzt.wzt@gmail.com wrote:
>
>> This one may break user space tools that have assumptions about the length
>> of the field. Or do tools not make that assumption?
>
> User space tools usually use sscanf() to extract this field like:
> sscanf(buff, "%s %d", name,&num);
> If %-27s can break some user space tools that have assumptions about
> the length of the field, the orig %-17s can also break it.
> The longest name inotify_event_private_data is 26 bytes in 2.6.34-rc2,
> the tools still can't extract it.

NAK. It's an ABI so the risks of this format cleanup outweight the benefits.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
