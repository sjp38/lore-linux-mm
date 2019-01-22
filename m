Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4B6ED8E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 04:09:09 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id z10so9069861edz.15
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 01:09:09 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v27si716720edm.111.2019.01.22.01.09.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 01:09:07 -0800 (PST)
Subject: Re: [Xen-devel] [PATCH 2/2] x86/xen: dont add memory above max
 allowed allocation
References: =?UTF-8?B?PDIwMTkwMTIyMDgwNjI4LjcyMzjvv70x77+9amdyb3NzQHN1c2Uu?=
 =?UTF-8?Q?com=3e_=3c20190122080628=2e7238-3-jgross=40suse=2ecom=3e_=3c5C46D?=
 =?UTF-8?Q?9D00200007800210007=40suse=2ecom=3e?=
From: Juergen Gross <jgross@suse.com>
Message-ID: <8872a401-46e1-ae81-e84e-0e70bdde2cce@suse.com>
Date: Tue, 22 Jan 2019 10:09:05 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Beulich <JBeulich@suse.com>
Cc: Borislav Petkov <bp@alien8.de>, Stefano Stabellini <sstabellini@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, xen-devel <xen-devel@lists.xenproject.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, mingo@redhat.com, lkml <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>

On 22/01/2019 09:52, Jan Beulich wrote:
>>>> On 22.01.19 at 09:06, <jgross@suse.com> wrote:
>> Don't allow memory to be added above the allowed maximum allocation
>> limit set by Xen.
> 
> This reads as if the hypervisor was imposing a limit here, but looking at
> xen_get_max_pages(), xen_foreach_remap_area(), and
> xen_count_remap_pages() I take it that it's a restriction enforced by
> the Xen subsystem in Linux. Furthermore from the cover letter I imply
> that the observed issue was on a Dom0, yet xen_get_max_pages()'s
> use of XENMEM_maximum_reservation wouldn't impose any limit there
> at all (without use of the hypervisor option "dom0_mem=max:..."),
> would it?

Oh yes, you are right, of course!

I need to check the current reservation and adjust the allowed limit
in case of ballooning and/or memory hotplug.

Thanks for noticing that!


Juergen
