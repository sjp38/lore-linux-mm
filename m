Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2D175828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 20:49:51 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id ba1so368879625obb.3
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 17:49:51 -0800 (PST)
Received: from mail-oi0-x22a.google.com (mail-oi0-x22a.google.com. [2607:f8b0:4003:c06::22a])
        by mx.google.com with ESMTPS id oo8si8298311obb.53.2016.01.08.17.49.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 17:49:50 -0800 (PST)
Received: by mail-oi0-x22a.google.com with SMTP id o124so13588886oia.3
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 17:49:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <19f6403f2b04d3448ed2ac958e656645d8b6e70c.1452297867.git.tony.luck@intel.com>
References: <cover.1452297867.git.tony.luck@intel.com> <19f6403f2b04d3448ed2ac958e656645d8b6e70c.1452297867.git.tony.luck@intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 8 Jan 2016 17:49:30 -0800
Message-ID: <CALCETrVqn58pMkMc09vbtNdbU2VFtQ=W8APZ0EqtLCh3JGvxoA@mail.gmail.com>
Subject: Re: [PATCH v8 3/3] x86, mce: Add __mcsafe_copy()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: linux-nvdimm <linux-nvdimm@ml01.01.org>, Dan Williams <dan.j.williams@intel.com>, Borislav Petkov <bp@alien8.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Robert <elliott@hpe.com>, Ingo Molnar <mingo@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On Jan 8, 2016 4:19 PM, "Tony Luck" <tony.luck@intel.com> wrote:
>
> Make use of the EXTABLE_FAULT exception table entries. This routine
> returns a structure to indicate the result of the copy:

Perhaps this is silly, but could we make this feature depend on ERMS
and thus make the code a lot simpler?

Also, what's the sfence for?  You don't seem to be using any
non-temporal operations.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
