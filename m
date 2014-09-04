Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id D19696B0036
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 16:21:55 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fb1so20741729pad.13
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 13:21:54 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id bi17si5418433pdb.236.2014.09.04.13.21.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Sep 2014 13:21:53 -0700 (PDT)
Message-ID: <5408C9C4.1010705@zytor.com>
Date: Thu, 04 Sep 2014 13:21:24 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] x86, mm, pat: Set WT to PA4 slot of PAT MSR
References: <1409855739-8985-1-git-send-email-toshi.kani@hp.com> <1409855739-8985-2-git-send-email-toshi.kani@hp.com> <20140904201123.GA9116@khazad-dum.debian.net>
In-Reply-To: <20140904201123.GA9116@khazad-dum.debian.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Toshi Kani <toshi.kani@hp.com>
Cc: tglx@linutronix.de, mingo@redhat.com, akpm@linuxfoundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, konrad.wilk@oracle.com

On 09/04/2014 01:11 PM, Henrique de Moraes Holschuh wrote:
> 
> I am worried of uncharted territory, here.  I'd actually advocate for not
> enabling the upper four PAT entries on IA-32 at all, unless Windows 9X / XP
> is using them as well.  Is this a real concern, or am I being overly
> cautious?
> 

It is extremely unlikely that we'd have PAT issues in 32-bit mode and
not in 64-bit mode on the same CPU.

As far as I know, the current blacklist rule is very conservative due to
lack of testing more than anything else.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
