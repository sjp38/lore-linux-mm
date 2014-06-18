Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 20A2E6B0037
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 10:41:17 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so815913pab.16
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 07:41:16 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id mi7si2438151pab.136.2014.06.18.07.41.15
        for <linux-mm@kvack.org>;
        Wed, 18 Jun 2014 07:41:16 -0700 (PDT)
Message-ID: <53A1A509.4080802@intel.com>
Date: Wed, 18 Jun 2014 07:41:13 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 00/10] Intel MPX support
References: <1403084656-27284-1-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1403084656-27284-1-git-send-email-qiaowei.ren@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

On 06/18/2014 02:44 AM, Qiaowei Ren wrote:
> This patchset adds support for the Memory Protection Extensions
> (MPX) feature found in future Intel processors.

It's very important to note that this is a very different patch set than
the last one.  The way we are freeing the unused bounds tables is
_completely different (9/10), and needs some very heavy mm reviews.  I'm
sure Qiaowei will cc linux-mm@ next time.

We're also not asking that this be merged in its current state.  The
32-bit binary on 64-bit kernel issue is a show stopper for merging, but
we're trying to post early and often.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
