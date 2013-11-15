Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 45BE06B0031
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 18:33:59 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rp16so4235701pbb.31
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 15:33:58 -0800 (PST)
Received: from psmtp.com ([74.125.245.188])
        by mx.google.com with SMTP id bf6si3275200pad.48.2013.11.15.15.33.57
        for <linux-mm@kvack.org>;
        Fri, 15 Nov 2013 15:33:58 -0800 (PST)
Received: by mail-vc0-f171.google.com with SMTP id lc6so2243336vcb.30
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 15:33:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131115231548.60418E0090@blue.fi.intel.com>
References: <1383833644-27091-1-git-send-email-kirill.shutemov@linux.intel.com>
	<CA+8MBbL-WpcC6_wfZeFW6Buqq0p1PStH5ScF-USHae40H3MXfg@mail.gmail.com>
	<CA+8MBbJR+AbGY41=TMOfJUd2u927ADa8O_-12sFUcNYnN34oMw@mail.gmail.com>
	<20131115231548.60418E0090@blue.fi.intel.com>
Date: Fri, 15 Nov 2013 15:33:55 -0800
Message-ID: <CA+8MBbLNbchh67DfCo_ntZ42yYUy4ttn8uODV-mEyG9KhFwcNg@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: Properly separate the bloated ptl from the
 regular case
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Nov 15, 2013 at 3:15 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> -#include <linux/spinlock.h>
> +#include <linux/spinlock_types.h>

Awesome!

Tested-by: Tony Luck <tony.luck@intel.com>

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
