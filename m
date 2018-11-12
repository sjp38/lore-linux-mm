Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 374F46B0272
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 05:29:25 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id h68so23023070qke.3
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 02:29:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d56si8748288qte.191.2018.11.12.02.29.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 02:29:24 -0800 (PST)
From: Florian Weimer <fweimer@redhat.com>
Subject: Re: pkeys: Reserve PKEY_DISABLE_READ
References: <877ehnbwqy.fsf@oldenburg.str.redhat.com>
	<20181108192226.GC5481@ram.oc3035372033.ibm.com>
Date: Mon, 12 Nov 2018 11:29:17 +0100
In-Reply-To: <20181108192226.GC5481@ram.oc3035372033.ibm.com> (Ram Pai's
	message of "Thu, 8 Nov 2018 11:22:26 -0800")
Message-ID: <87bm6utwqq.fsf@oldenburg.str.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: linux-api@vger.kernel.org, linux-mm@kvack.org, dave.hansen@intel.com, linuxppc-dev@lists.ozlabs.org

* Ram Pai:

> On Thu, Nov 08, 2018 at 01:05:09PM +0100, Florian Weimer wrote:
>> Would it be possible to reserve a bit for PKEY_DISABLE_READ?
>> 
>> I think the POWER implementation can disable read access at the hardware
>> level, but not write access, and that cannot be expressed with the
>> current PKEY_DISABLE_ACCESS and PKEY_DISABLE_WRITE bits.
>
> POWER hardware can disable-read and can **also disable-write**
> at the hardware level. It can disable-execute aswell at the
> hardware level.   For example if the key bits for a given key in the AMR
> register is  
> 	0b01  it is read-disable
> 	0b10  it is write-disable
>
> To support access-disable, we make the key value 0b11.
>
> So in case if you want to know if the key is read-disable 'bitwise-and' it
> against 0x1.  i.e  (x & 0x1)

Not sure if we covered that alreay, but my problem is that I cannot
translate a 0b01 mask to a PKEY_DISABLE_* flag combination with the
current flags.  0b10 and 0b11 are fine.

POWER also loses the distinction between PKEY_DISABLE_ACCESS and
PKEY_DISABLE_ACCESS | PKEY_DISABLE_WRITE, but that's fine.  This breaks
the current glibc test case, but I have a patch for that.  Arguably, the
test is wrong or at least overly strict in what it accepts.

Thanks,
Florian
