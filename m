Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id C6F3F6B0035
	for <linux-mm@kvack.org>; Sat, 13 Sep 2014 05:39:58 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id e4so1831712wiv.11
        for <linux-mm@kvack.org>; Sat, 13 Sep 2014 02:39:58 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id g4si11555684wjy.73.2014.09.13.02.39.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Sat, 13 Sep 2014 02:39:56 -0700 (PDT)
Date: Sat, 13 Sep 2014 11:39:42 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v8 00/10] Intel MPX support
In-Reply-To: <54136EC4.6000905@intel.com>
Message-ID: <alpine.DEB.2.10.1409131138290.23397@nanos>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <54124379.5090502@intel.com> <alpine.DEB.2.10.1409121543090.4178@nanos> <54136EC4.6000905@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 12 Sep 2014, Dave Hansen wrote:

> OK, here's some revised text for patch 00/10.  Again, this will
> obviously be updated for the next post, but comments before that would
> be much appreciated.

That looks good. So much of this wants to end up in documentation as
well.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
