Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0C9066B0038
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 08:57:51 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id j13so63278186iod.6
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 05:57:51 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id s11si12788727pgc.259.2017.01.13.05.57.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 05:57:50 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id 127so8561241pfg.0
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 05:57:50 -0800 (PST)
From: Balbir Singh <bsingharora@gmail.com>
Date: Fri, 13 Jan 2017 19:27:41 +0530
Subject: Re: [HMM v16 01/15] mm/memory/hotplug: convert device bool to int to
 allow for more flags v2
Message-ID: <20170113135741.GA26827@localhost.localdomain>
References: <1484238642-10674-1-git-send-email-jglisse@redhat.com>
 <1484238642-10674-2-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1484238642-10674-2-git-send-email-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Russell King <linux@armlinux.org.uk>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

On Thu, Jan 12, 2017 at 11:30:28AM -0500, Jerome Glisse wrote:
> When hotpluging memory we want more informations on the type of memory and
> its properties. Replace the device boolean flag by an int and define a set
> of flags.
> 
> New property for device memory is an opt-in flag to allow page migration
> from and to a ZONE_DEVICE. Existing user of ZONE_DEVICE are not expecting
> page migration to work for their pages. New changes to page migration i
> changing that and we now need a flag to explicitly opt-in page migration.

Given that ZONE_DEVICE is dependent on X86_64, do we need to touch all
architectures? I guess we could selectively enable things as we enable
ZONE_DEVICE for other architectures?

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
