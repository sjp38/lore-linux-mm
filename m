Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1A9DD6B003A
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 16:10:40 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id v10so7671793pde.34
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 13:10:39 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id ou8si6271787pdb.505.2014.07.15.13.10.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jul 2014 13:10:39 -0700 (PDT)
Message-ID: <53C58A9C.6070906@zytor.com>
Date: Tue, 15 Jul 2014 13:10:04 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/11] Support Write-Through mapping on x86
References: <1405452884-25688-1-git-send-email-toshi.kani@hp.com> <CALCETrVfqBpJaTJCnDH8pZf4-6x6oojv+8Vvm3XudJfhbstdOQ@mail.gmail.com>
In-Reply-To: <CALCETrVfqBpJaTJCnDH8pZf4-6x6oojv+8Vvm3XudJfhbstdOQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Toshi Kani <toshi.kani@hp.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, plagnioj@jcrosoft.com, tomi.valkeinen@ti.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Dave Airlie <airlied@gmail.com>, Borislav Petkov <bp@alien8.de>

On 07/15/2014 12:53 PM, Andy Lutomirski wrote:
> 
> Note that MTRRs are already partially deprecated: all drivers *should*
> be using arch_phys_wc_add, not mtrr_add, and arch_phys_wc_add is a
> no-op on systems with working PAT.
> 
> Unfortunately, I never finished excising mtrr_add.  Finishing the job
> wouldn't be very hard.
> 

The use of MTRRs in drivers is separate from the MTRR global setup done
by the firmware, though.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
