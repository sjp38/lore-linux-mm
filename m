Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 05B806B007B
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 09:13:41 -0400 (EDT)
Message-ID: <ae2bdc3089ce0adec73f3d9c52dac609.squirrel@webmail.sf-mail.de>
In-Reply-To: <BANLkTi=LcCiy=wroAuDdcfe3QnfXxke0ww@mail.gmail.com>
References: <20110602142242.GA4115@maxin>
    <BANLkTimYw-WAK3Hd21XQWrjBn_1+wRMzUQ@mail.gmail.com>
    <3838457.LEWxWdrTRM@donald.sf-tec.de>
    <BANLkTi=LcCiy=wroAuDdcfe3QnfXxke0ww@mail.gmail.com>
Date: Wed, 8 Jun 2011 15:13:36 +0200
Subject: Re: [PATCH] mm: dmapool: fix possible use after free in
 dmam_pool_destroy()
From: "Rolf Eike Beer" <eike-kernel@sf-tec.de>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxin B John <maxin.john@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dima@android.com, willy@linux.intel.com, segooon@gmail.com, tj@kernel.org, jkosina@suse.cz, tglx@linutronix.de

> Hi,
>
> On Tue, Jun 7, 2011 at 7:05 PM, Rolf Eike Beer <eike-kernel@sf-tec.de>
> wrote:
>> Maxin B John wrote:
>>
>>> Could you please let me know your thoughts on this patch ?
>>
>> Makes absolute sense to me.
>>
>> Reviewed-by: Rolf Eike Beer <eike-kernel@sf-tec.de>
>
> Thanks a lot for reviewing the patch. Should I merge these two patches
> and re-send it as a single one ?

I would do so.

Eike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
