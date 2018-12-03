Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8D04F6B69F3
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 10:52:14 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id d35so13807411qtd.20
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 07:52:14 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n36si3453360qtk.240.2018.12.03.07.52.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 07:52:13 -0800 (PST)
From: Florian Weimer <fweimer@redhat.com>
Subject: Re: pkeys: Reserve PKEY_DISABLE_READ
References: <6f9c65fb-ea7e-8217-a4cc-f93e766ed9bb@intel.com>
	<87k1ln8o7u.fsf@oldenburg.str.redhat.com>
	<20181108201231.GE5481@ram.oc3035372033.ibm.com>
	<87bm6z71yw.fsf@oldenburg.str.redhat.com>
	<20181109180947.GF5481@ram.oc3035372033.ibm.com>
	<87efbqqze4.fsf@oldenburg.str.redhat.com>
	<20181127102350.GA5795@ram.oc3035372033.ibm.com>
	<87zhtuhgx0.fsf@oldenburg.str.redhat.com>
	<58e263a6-9a93-46d6-c5f9-59973064d55e@intel.com>
	<87va4g5d3o.fsf@oldenburg.str.redhat.com>
	<20181203040249.GA11930@ram.oc3035372033.ibm.com>
Date: Mon, 03 Dec 2018 16:52:02 +0100
In-Reply-To: <20181203040249.GA11930@ram.oc3035372033.ibm.com> (Ram Pai's
	message of "Sun, 2 Dec 2018 20:02:49 -0800")
Message-ID: <87pnuibobh.fsf@oldenburg.str.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

* Ram Pai:

> So the problem is as follows:
>
> Currently the kernel supports  'disable-write'  and 'disable-access'.
>
> On x86, cpu supports 'disable-write' and 'disable-access'. This
> matches with what the kernel supports. All good.
>
> However on power, cpu supports 'disable-read' too. Since userspace can
> program the cpu directly, userspace has the ability to set
> 'disable-read' too.  This can lead to inconsistency between the kernel
> and the userspace.
>
> We want the kernel to match userspace on all architectures.

Correct.

> Proposed Solution:
>
> Enhance the kernel to understand 'disable-read', and facilitate architectures
> that understand 'disable-read' to allow it.
>
> Also explicitly define the semantics of disable-access  as 
> 'disable-read and disable-write'
>
> Did I get this right?  Assuming I did, the implementation has to do
> the following --
>   
> 	On power, sys_pkey_alloc() should succeed if the init_val
> 	is PKEY_DISABLE_READ, PKEY_DISABLE_WRITE, PKEY_DISABLE_ACCESS
> 	or any combination of the three.

Agreed.

> 	On x86, sys_pkey_alloc() should succeed if the init_val is
> 	PKEY_DISABLE_WRITE or PKEY_DISABLE_ACCESS or PKEY_DISABLE_READ
> 	or any combination of the three, except  PKEY_DISABLE_READ
>       	specified all by itself.

Again agreed.  That's a clever way of phrasing it actually.

> 	On all other arches, none of the flags are supported.
>
>
> Are we on the same plate?

I think so, thanks.

Florian
