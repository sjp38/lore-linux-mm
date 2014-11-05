Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3DC9B6B0071
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 17:58:54 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id y13so1647609pdi.20
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 14:58:53 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id ku8si4090872pbc.247.2014.11.05.14.58.51
        for <linux-mm@kvack.org>;
        Wed, 05 Nov 2014 14:58:52 -0800 (PST)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Documentation: vm: Add 1GB large page support information
References: <1414771317-5721-1-git-send-email-standby24x7@gmail.com>
	<5457C6EA.3080809@intel.com>
	<CALLJCT0fofgUaswpzt1iBqGS1u+fR8L=umwGpV=RG0SvO9TOJA@mail.gmail.com>
	<545A42C4.6070908@intel.com>
Date: Wed, 05 Nov 2014 14:58:51 -0800
In-Reply-To: <545A42C4.6070908@intel.com> (Dave Hansen's message of "Wed, 05
	Nov 2014 07:31:16 -0800")
Message-ID: <871tphtftg.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Masanari Iida <standby24x7@gmail.com>, Jonathan Corbet <corbet@lwn.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, lcapitulino@redhat.com

Dave Hansen <dave.hansen@intel.com> writes:

> On 11/05/2014 07:21 AM, Masanari Iida wrote:
>> Luiz, Dave,
>> Thanks for comments.
>> 
>> I understand that there are some exception cases which doesn't support 1G
>> large pages on newer CPUs.
>> I like Dave's example, at the same time I would like to add "pdpe1gb flag" in
>> the document.
>> 
>> For example, x86 CPUs normally support 4K and 2M (1G if pdpe1gb flag exist).
>
> Is 1G supported on CPUs that have pdpe1gb and are running a 32-bit kernel?

No, 1GB pages is a 64bit only feature.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
