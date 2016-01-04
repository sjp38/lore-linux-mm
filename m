Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id DE4D76B0005
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 17:23:41 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id wp13so125257211obc.1
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 14:23:41 -0800 (PST)
Received: from mail-oi0-x22b.google.com (mail-oi0-x22b.google.com. [2607:f8b0:4003:c06::22b])
        by mx.google.com with ESMTPS id t132si1905142oib.144.2016.01.04.14.23.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 14:23:41 -0800 (PST)
Received: by mail-oi0-x22b.google.com with SMTP id l9so236043902oia.2
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 14:23:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160104203212.GP22941@pd.tnic>
References: <cover.1451869360.git.tony.luck@intel.com> <18380d9d19d5165822d12532127de2fb7a8b8cc7.1451869360.git.tony.luck@intel.com>
 <20160104142213.GI22941@pd.tnic> <3908561D78D1C84285E8C5FCA982C28F39F9FF79@ORSMSX114.amr.corp.intel.com>
 <20160104203212.GP22941@pd.tnic>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 4 Jan 2016 14:23:21 -0800
Message-ID: <CALCETrX9_itvAUdc1P4DA3GX9aHnkJYu1P4dH5ACzpYQvM7ccA@mail.gmail.com>
Subject: Re: [PATCH v6 2/4] x86: Cleanup and add a new exception class
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: "Luck, Tony" <tony.luck@intel.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "elliott@hpe.com" <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "x86@kernel.org" <x86@kernel.org>

On Mon, Jan 4, 2016 at 12:32 PM, Borislav Petkov <bp@alien8.de> wrote:
> On Mon, Jan 04, 2016 at 05:00:04PM +0000, Luck, Tony wrote:
>> > So you're touching those again in patch 2. Why not add those defines to
>> > patch 1 directly and diminish the churn?
>>
>> To preserve authorship. Andy did patch 1 (the clever part). Patch 2 is just syntactic
>> sugar on top of it.
>
> That you can do in the way Ingo suggested.

I also personally don't care that much.  You're welcome to modify my patch.

If you modify it so much that it's mostly your patch, then change the
From: string and credit me.  If not, leave the author as me and make a
note in the log message.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
