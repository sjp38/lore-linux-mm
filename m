Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3C08B6B0071
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 18:07:58 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id lj1so1716803pab.8
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 15:07:57 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id lh16si4242597pab.123.2014.11.05.15.07.56
        for <linux-mm@kvack.org>;
        Wed, 05 Nov 2014 15:07:56 -0800 (PST)
Message-ID: <545AADCC.5030102@intel.com>
Date: Wed, 05 Nov 2014 15:07:56 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Documentation: vm: Add 1GB large page support information
References: <1414771317-5721-1-git-send-email-standby24x7@gmail.com>	<5457C6EA.3080809@intel.com>	<CALLJCT0fofgUaswpzt1iBqGS1u+fR8L=umwGpV=RG0SvO9TOJA@mail.gmail.com>	<545A42C4.6070908@intel.com> <871tphtftg.fsf@tassilo.jf.intel.com>
In-Reply-To: <871tphtftg.fsf@tassilo.jf.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Masanari Iida <standby24x7@gmail.com>, Jonathan Corbet <corbet@lwn.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, lcapitulino@redhat.com

On 11/05/2014 02:58 PM, Andi Kleen wrote:
>>> >> I understand that there are some exception cases which doesn't support 1G
>>> >> large pages on newer CPUs.
>>> >> I like Dave's example, at the same time I would like to add "pdpe1gb flag" in
>>> >> the document.
>>> >> 
>>> >> For example, x86 CPUs normally support 4K and 2M (1G if pdpe1gb flag exist).
>> >
>> > Is 1G supported on CPUs that have pdpe1gb and are running a 32-bit kernel?
> No, 1GB pages is a 64bit only feature.

This is one sentence in a document that nobody reads, so we're all
putting way more brainpower in to this than we should.

We can't universally say that "1G if pdpe1gb flag exist" since a 64-bit
CPU running a 32-bit kernel doesn't support 1G pages *despite* the
presence of pdpe1gb.  I think that makes it a pretty crappy thing to put
in a document since it's just misleading.  We can't spell out all the
pitfalls or all the possible combinations, and it's not the place of our
stupid documentation to repeat what's in the architecture manuals.

	For example, x86 CPUs normally support 4K and 2M (1G if
	architecturally supported).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
