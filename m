Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 678086B025D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 22:22:04 -0500 (EST)
Received: by obciw8 with SMTP id iw8so74083870obc.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 19:22:04 -0800 (PST)
Received: from mail-ob0-x233.google.com (mail-ob0-x233.google.com. [2607:f8b0:4003:c01::233])
        by mx.google.com with ESMTPS id r5si6974430obf.99.2015.12.10.19.22.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 19:22:03 -0800 (PST)
Received: by obc18 with SMTP id 18so73162504obc.2
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 19:22:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <cover.1449702533.git.luto@kernel.org>
References: <cover.1449702533.git.luto@kernel.org>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 10 Dec 2015 19:21:44 -0800
Message-ID: <CALCETrXbwTAQz7=GZwhF9Py5BXjG3njeB993r_pkorZLSrgD=A@mail.gmail.com>
Subject: Re: [PATCH 0/5] x86: KVM vdso and clock improvements
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Dec 10, 2015 at 7:20 PM, Andy Lutomirski <luto@kernel.org> wrote:
> NB: patch 1 doesn't really belong here, but it makes this a lot

Ugh, please disregard the resend.  I typoed my git send-email command slightly.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
