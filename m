Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id B3CB26B0003
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 02:11:11 -0500 (EST)
Received: by mail-yk0-f175.google.com with SMTP id v14so214000711ykd.3
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 23:11:11 -0800 (PST)
Received: from mail-yk0-x232.google.com (mail-yk0-x232.google.com. [2607:f8b0:4002:c07::232])
        by mx.google.com with ESMTPS id j67si51564249ywc.11.2016.01.05.23.11.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 23:11:11 -0800 (PST)
Received: by mail-yk0-x232.google.com with SMTP id k129so284901923yke.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 23:11:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <A527EC4B-4069-4FDE-BE4C-5279C45BCABE@intel.com>
References: <cover.1451952351.git.tony.luck@intel.com>
	<5b0243c5df825ad0841f4bb5584cd15d3f013f09.1451952351.git.tony.luck@intel.com>
	<CAPcyv4jjWT3Od_XvGpVb+O7MT95mBRXviPXi1zUfM5o+kN4CUA@mail.gmail.com>
	<A527EC4B-4069-4FDE-BE4C-5279C45BCABE@intel.com>
Date: Tue, 5 Jan 2016 23:11:10 -0800
Message-ID: <CAPcyv4iijhdXnD-4PuHkzbhhPra8eCRZ=df3XTE=z-efbQmVww@mail.gmail.com>
Subject: Re: [PATCH v7 3/3] x86, mce: Add __mcsafe_copy()
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Tue, Jan 5, 2016 at 11:06 PM, Luck, Tony <tony.luck@intel.com> wrote:
> You were heading towards:
>
> ld: undefined __mcsafe_copy

True, we'd also need a dummy mcsafe_copy() definition to compile it
out in the disabled case.

> since that is also inside the #ifdef.
>
> Weren't you going to "select" this?
>

I do select it, but by randconfig I still need to handle the
CONFIG_X86_MCE=n case.

> I'm seriously wondering whether the ifdef still makes sense. Now I don't have an extra exception table and routines to sort/search/fixup, it doesn't seem as useful as it was a few iterations ago.

Either way is ok with me.  That said, the extra definitions to allow
it compile out when not enabled don't seem too onerous.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
