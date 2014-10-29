Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id A5FCA90008B
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 17:37:49 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id q5so2903216wiv.16
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 14:37:49 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id gd4si20031354wib.6.2014.10.29.14.37.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 29 Oct 2014 14:37:48 -0700 (PDT)
Date: Wed, 29 Oct 2014 22:37:44 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: mmotm 2014-10-29-14-19 uploaded
In-Reply-To: <54515a25.46WrYSce5BExT3V4%akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.11.1410292233340.5308@nanos>
References: <54515a25.46WrYSce5BExT3V4%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mm-commits@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

On Wed, 29 Oct 2014, akpm@linux-foundation.org wrote:
> This mmotm tree contains the following patches against 3.18-rc2:
> (patches marked "*" will be included in linux-next)
> 
> * kernel-posix-timersc-code-clean-up.patch

Can you please drop this pointless churn? We really can replace all
that stuff with a shell script and let it run over the tree every now
and then.

Especially if that humanoid "checkpatch.pl" replacement requires a
checkpatch.pl fixup itself.

> * kernel-posix-timersc-code-clean-up-checkpatch-fixes.patch

That's beyond silly, really.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
