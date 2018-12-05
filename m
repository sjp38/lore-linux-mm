Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 579326B7471
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 08:01:04 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id f22so19661195qkm.11
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 05:01:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i13si7413683qtm.380.2018.12.05.05.01.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 05:01:03 -0800 (PST)
From: Florian Weimer <fweimer@redhat.com>
Subject: Re: pkeys: Reserve PKEY_DISABLE_READ
References: <20181108201231.GE5481@ram.oc3035372033.ibm.com>
	<87bm6z71yw.fsf@oldenburg.str.redhat.com>
	<20181109180947.GF5481@ram.oc3035372033.ibm.com>
	<87efbqqze4.fsf@oldenburg.str.redhat.com>
	<20181127102350.GA5795@ram.oc3035372033.ibm.com>
	<87zhtuhgx0.fsf@oldenburg.str.redhat.com>
	<58e263a6-9a93-46d6-c5f9-59973064d55e@intel.com>
	<87va4g5d3o.fsf@oldenburg.str.redhat.com>
	<20181203040249.GA11930@ram.oc3035372033.ibm.com>
	<87pnuibobh.fsf@oldenburg.str.redhat.com>
	<20181204062318.GC11930@ram.oc3035372033.ibm.com>
Date: Wed, 05 Dec 2018 14:00:59 +0100
In-Reply-To: <20181204062318.GC11930@ram.oc3035372033.ibm.com> (Ram Pai's
	message of "Mon, 3 Dec 2018 22:23:18 -0800")
Message-ID: <87zhtki0vo.fsf@oldenburg2.str.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

* Ram Pai:

> Ok. here is a patch, compiled but not tested. See if this meets the
> specifications.
>
> -----------------------------------------------------------------------------------
>
> commit 3dc06e73f3795921265d5d1d935e428deab01616
> Author: Ram Pai <linuxram@us.ibm.com>
> Date:   Tue Dec 4 00:04:11 2018 -0500
>
>     pkeys: add support of PKEY_DISABLE_READ

Thanks.  In the x86 code, the translation of PKEY_DISABLE_READ |
PKEY_DISABLE_WRITE to PKEY_DISABLE_ACCESS appears to be missing.  I
believe the existing code produces PKEY_DISABLE_WRITE, which is wrong.

Rest looks okay to me (again not tested).

Thanks,
Florian
