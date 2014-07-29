Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 401C56B0036
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 13:29:24 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id x13so9314270wgg.19
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 10:29:22 -0700 (PDT)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id ng20si21124858wic.7.2014.07.29.10.29.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Jul 2014 10:29:21 -0700 (PDT)
Received: by mail-wi0-f169.google.com with SMTP id n3so5748503wiv.4
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 10:29:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1406530260-26078-1-git-send-email-gong.chen@linux.intel.com>
References: <1406530260-26078-1-git-send-email-gong.chen@linux.intel.com>
Date: Tue, 29 Jul 2014 10:29:19 -0700
Message-ID: <CA+8MBbLmLOHKpnvCu2=SUAB8yTupaVxoBP3HNQLLTxOKSHj1xQ@mail.gmail.com>
Subject: Re: two minor update patches for RAS
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Chen, Gong" <gong.chen@linux.intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Borislav Petkov <bp@alien8.de>, linux-acpi <linux-acpi@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sun, Jul 27, 2014 at 11:50 PM, Chen, Gong <gong.chen@linux.intel.com> wrote:
> [PATCH 1/2] APEI, GHES: Cleanup unnecessary function for lock-less
> [PATCH 2/2] RAS, HWPOISON: Fix wrong error recovery status

both parts:

Acked-by: Tony Luck <tony.luck@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
