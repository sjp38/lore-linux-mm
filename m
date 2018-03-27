Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 004686B0025
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 12:32:29 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id n15-v6so259959plp.22
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 09:32:29 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id x12-v6si1544198plo.129.2018.03.27.09.32.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Mar 2018 09:32:29 -0700 (PDT)
Subject: Re: [PATCH 00/11] Use global pages with PTI
References: <20180323174447.55F35636@viggo.jf.intel.com>
 <CA+55aFwEC1O+6qRc35XwpcuLSgJ+0GP6ciqw_1Oc-msX=efLvQ@mail.gmail.com>
 <be2e683c-bf0a-e9ce-2f02-4905f6bd56d3@linux.intel.com>
 <alpine.DEB.2.21.1803271526260.1964@nanos.tec.linutronix.de>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <c0e7ca0b-dcb5-66e2-9df6-f53e4eb22781@linux.intel.com>
Date: Tue, 27 Mar 2018 09:32:27 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1803271526260.1964@nanos.tec.linutronix.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, the arch/x86 maintainers <x86@kernel.org>, namit@vmware.com

On 03/27/2018 06:36 AM, Thomas Gleixner wrote:
>>                         User Time       Kernel Time     Clock Elapsed
>> Baseline ( 0 GLB PTEs)  803.79          67.77           237.30
>> w/series (28 GLB PTEs)  807.70 (+0.7%)  68.07 (+0.7%)   238.07 (+0.3%)
>>
>> Without PCIDs, it behaves the way I would expect.
> What's the performance benefit on !PCID systems? And I mean systems which
> actually do not have PCID, not a PCID system with 'nopcid' on the command
> line.

Do you have something in mind for this?  Basically *all* of the servers
that I have access to have PCID because they are newer than ~7 years old.

That leaves *some* Ivybridge and earlier desktops, Atoms and AMD
systems.  Atoms are going to be the easiest thing to get my hands on,
but I tend to shy away from them for performance work.
