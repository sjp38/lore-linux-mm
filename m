Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 8AFB36B0038
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 01:30:33 -0500 (EST)
Received: by mail-ig0-f169.google.com with SMTP id z20so597401igj.0
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 22:30:33 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id hv9si6141740igb.0.2015.01.08.22.30.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jan 2015 22:30:32 -0800 (PST)
Date: Thu, 8 Jan 2015 22:30:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mm performance with zram
Message-Id: <20150108223024.da818218.akpm@linux-foundation.org>
In-Reply-To: <CAA25o9Sf62u3mJtBp_swLL0RS2Zb=EjZtWERJqyrbBpk7-bP-A@mail.gmail.com>
References: <CAA25o9Sf62u3mJtBp_swLL0RS2Zb=EjZtWERJqyrbBpk7-bP-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: linux-mm@kvack.org

On Thu, 8 Jan 2015 14:49:45 -0800 Luigi Semenzato <semenzato@google.com> wrote:

> I am taking a closer look at the performance of the Linux MM in the
> context of heavy zram usage.  The bottom line is that there is
> surprisingly high overhead (35-40%) from MM code other than
> compression/decompression routines.

Those images hurt my eyes.

Did you work out where the time is being spent?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
