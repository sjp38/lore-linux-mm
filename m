Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id DD3396B0611
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 09:57:53 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id y144-v6so18360220pfb.10
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 06:57:53 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id p20si848810pgm.455.2018.11.08.06.57.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 06:57:52 -0800 (PST)
Subject: Re: pkeys: Reserve PKEY_DISABLE_READ
References: <877ehnbwqy.fsf@oldenburg.str.redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <2d62c9e2-375b-2791-32ce-fdaa7e7664fd@intel.com>
Date: Thu, 8 Nov 2018 06:57:51 -0800
MIME-Version: 1.0
In-Reply-To: <877ehnbwqy.fsf@oldenburg.str.redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>, linux-api@vger.kernel.org, linux-mm@kvack.org
Cc: linuxram@us.ibm.com

On 11/8/18 4:05 AM, Florian Weimer wrote:
> Would it be possible to reserve a bit for PKEY_DISABLE_READ?
> 
> I think the POWER implementation can disable read access at the hardware
> level, but not write access, and that cannot be expressed with the
> current PKEY_DISABLE_ACCESS and PKEY_DISABLE_WRITE bits.

Do you just mean in the syscall interfaces?  What would we need to do on
x86 if we see the bit?  Would we just say it's invalid on x86, or would
we make sure that PKEY_DISABLE_ACCESS==PKEY_DISABLE_READ?
