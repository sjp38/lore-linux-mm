Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 84C886B0035
	for <linux-mm@kvack.org>; Sun,  7 Sep 2014 09:59:09 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id kq14so25390145pab.36
        for <linux-mm@kvack.org>; Sun, 07 Sep 2014 06:59:09 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id zp8si13151382pac.130.2014.09.07.06.59.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Sep 2014 06:59:07 -0700 (PDT)
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by gateway2.nyi.internal (Postfix) with ESMTP id C71D420723
	for <linux-mm@kvack.org>; Sun,  7 Sep 2014 09:59:03 -0400 (EDT)
Date: Sun, 7 Sep 2014 10:58:50 -0300
From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: [PATCH 1/5] x86, mm, pat: Set WT to PA4 slot of PAT MSR
Message-ID: <20140907135850.GA23026@khazad-dum.debian.net>
References: <1409855739-8985-1-git-send-email-toshi.kani@hp.com>
 <1409855739-8985-2-git-send-email-toshi.kani@hp.com>
 <20140904201123.GA9116@khazad-dum.debian.net>
 <1409862708.28990.141.camel@misato.fc.hp.com>
 <1409873255.28990.158.camel@misato.fc.hp.com>
 <20140905102347.GA30096@gmail.com>
 <1409925023.28990.176.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1409925023.28990.176.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Ingo Molnar <mingo@kernel.org>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linuxfoundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, konrad.wilk@oracle.com

On Fri, 05 Sep 2014, Toshi Kani wrote:
> On Fri, 2014-09-05 at 12:23 +0200, Ingo Molnar wrote:
> > Any reason why we have to create such a sharp boundary, instead 
> > of simply saying: 'disable PAT on all x86 CPU families that have 
> > at least one buggy model'?
> > 
> > That would nicely sort out all the broken CPUs, and would make it 
> > highly unlikely that we'd accidentally forget about a model or 
> > two.
> 
> Agreed.  I will disable this feature on all Pentium 4 models as well.  I
> do not think there is any necessity to enable it on Pentium 4.

Thank you.  That takes care of my misguivings about enabling this on aging
platforms as well.

-- 
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
