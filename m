Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id DF58E6B007E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 06:46:37 -0400 (EDT)
Received: by qwa26 with SMTP id 26so226125qwa.14
        for <linux-mm@kvack.org>; Wed, 08 Jun 2011 03:46:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <3838457.LEWxWdrTRM@donald.sf-tec.de>
References: <20110602142242.GA4115@maxin>
	<BANLkTimYw-WAK3Hd21XQWrjBn_1+wRMzUQ@mail.gmail.com>
	<3838457.LEWxWdrTRM@donald.sf-tec.de>
Date: Wed, 8 Jun 2011 11:46:34 +0100
Message-ID: <BANLkTi=LcCiy=wroAuDdcfe3QnfXxke0ww@mail.gmail.com>
Subject: Re: [PATCH] mm: dmapool: fix possible use after free in dmam_pool_destroy()
From: Maxin B John <maxin.john@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rolf Eike Beer <eike-kernel@sf-tec.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dima@android.com, willy@linux.intel.com, segooon@gmail.com, tj@kernel.org, jkosina@suse.cz, tglx@linutronix.de

Hi,

On Tue, Jun 7, 2011 at 7:05 PM, Rolf Eike Beer <eike-kernel@sf-tec.de> wrote:
> Maxin B John wrote:
>
>> Could you please let me know your thoughts on this patch ?
>
> Makes absolute sense to me.
>
> Reviewed-by: Rolf Eike Beer <eike-kernel@sf-tec.de>

Thanks a lot for reviewing the patch. Should I merge these two patches
and re-send it as a single one ?

Please let me know your opinion.

Warm Regards,
Maxin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
