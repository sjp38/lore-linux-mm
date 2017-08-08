Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9916B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 12:48:19 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id f72so60438013ywb.4
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 09:48:19 -0700 (PDT)
Received: from mail-yw0-x22d.google.com (mail-yw0-x22d.google.com. [2607:f8b0:4002:c05::22d])
        by mx.google.com with ESMTPS id g63si461479ybb.713.2017.08.08.09.48.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 09:48:18 -0700 (PDT)
Received: by mail-yw0-x22d.google.com with SMTP id p68so24934612ywg.0
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 09:48:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1502207168.6577.25.camel@redhat.com>
References: <20170806140425.20937-1-riel@redhat.com> <a0d79f77-f916-d3d6-1d61-a052581dbd4a@oracle.com>
 <bfdab709-e5b2-0d26-1c0f-31535eda1678@redhat.com> <1502198148.6577.18.camel@redhat.com>
 <0324df31-717d-32c1-95ef-351c5b23105f@oracle.com> <1502207168.6577.25.camel@redhat.com>
From: =?UTF-8?Q?Colm_MacC=C3=A1rthaigh?= <colm@allcosts.net>
Date: Tue, 8 Aug 2017 18:48:17 +0200
Message-ID: <CAAF6GDfgX-60OFonQ+Rm=bQRNhEVho_xdizHbqCvmOCk_AOPWQ@mail.gmail.com>
Subject: Re: [PATCH v2 0/2] mm,fork,security: introduce MADV_WIPEONFORK
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Florian Weimer <fweimer@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Kees Cook <keescook@chromium.org>, luto@amacapital.net, Will Drewry <wad@chromium.org>, mingo@kernel.org, kirill@shutemov.name, dave.hansen@intel.com

On Tue, Aug 8, 2017 at 5:46 PM, Rik van Riel <riel@redhat.com> wrote:

>> If the use case is fairly specific, then perhaps it makes sense to
>> make MADV_WIPEONFORK not applicable (EINVAL) for mappings where the
>> result is 'questionable'.
>
> That would be a question for Florian and Colm.
>
> If they are OK with MADV_WIPEONFORK only working on
> anonymous VMAs (no file mapping), that certainly could
> be implemented.

Anonymous would be sufficient for all of the Crypto-cases that I've
come across. But I can imagine someone wanting to initialize all
application state from a saved file, or share it between processes.

The comparable minherit call sidesteps all of this by simply
documenting that it results in a new anonymous page after fork, and so
the previous state doesn't matter.

Maybe the problem here is the poor name (my fault). WIPEONFORK
suggests an action being taken ... like a user might think that it
literally zeroes a file, for example.  At the risk of bike shedding:
maybe ZEROESONFORK would resolve that small ambiguity?

-- 
Colm

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
