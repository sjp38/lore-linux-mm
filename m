Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 917C56B0035
	for <linux-mm@kvack.org>; Tue, 20 May 2014 14:18:36 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id c13so820419eek.6
        for <linux-mm@kvack.org>; Tue, 20 May 2014 11:18:36 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id j42si4420744eeo.122.2014.05.20.11.18.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 May 2014 11:18:35 -0700 (PDT)
Message-ID: <537B9C6D.7010705@zytor.com>
Date: Tue, 20 May 2014 11:18:21 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] x86,mm: Improve _install_special_mapping and fix
 x86 vdso naming
References: <cover.1400538962.git.luto@amacapital.net> <276b39b6b645fb11e345457b503f17b83c2c6fd0.1400538962.git.luto@amacapital.net> <20140520172134.GJ2185@moon> <CALCETrWSgjc+iymPrvC9xiz1z4PqQS9e9F5mRLNnuabWTjQGQQ@mail.gmail.com> <20140520174759.GK2185@moon> <CALCETrUARCP0eNj5e3Kh81KDXg5AFLnoNoDHeoZcBXi9z-5F3w@mail.gmail.com> <20140520180104.GL2185@moon>
In-Reply-To: <20140520180104.GL2185@moon>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, Andy Lutomirski <luto@amacapital.net>
Cc: X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On 05/20/2014 11:01 AM, Cyrill Gorcunov wrote:
>>
>> This patch should fix this issue, at least.  If there's still a way to
>> get a native vdso that doesn't say "[vdso]", please let me know/
> 
> Yes, having a native procfs way to detect vdso is much preferred!
> 

Is there any path by which we can end up with [vdso] without a leading
slash in /proc/self/maps?  Otherwise, why is that not "native"?

>>>   The situation get worse when task was dumped on one kernel and
>>> then restored on another kernel where vdso content is different
>>> from one save in image -- is such case as I mentioned we need
>>> that named vdso proxy which redirect calls to vdso of the system
>>> where task is restoring. And when such "restored" task get checkpointed
>>> second time we don't dump new living vdso but save only old vdso
>>> proxy on disk (detecting it is a different story, in short we
>>> inject a unique mark into elf header).
>>
>> Yuck.  But I don't know whether the kernel can help much here.
> 
> Some prctl which would tell kernel to put vdso at specifed address.
> We can live without it for now so not a big deal (yet ;)

mremap() will do this for you.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
