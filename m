Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 249656B0038
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 09:45:13 -0500 (EST)
Received: by mail-yw0-f200.google.com with SMTP id l75so59084413ywb.0
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 06:45:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m130si3710258ywd.201.2017.01.13.06.45.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 06:45:12 -0800 (PST)
Date: Fri, 13 Jan 2017 09:45:08 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM v16 01/15] mm/memory/hotplug: convert device bool to int to
 allow for more flags v2
Message-ID: <20170113144508.GA3758@redhat.com>
References: <1484238642-10674-1-git-send-email-jglisse@redhat.com>
 <1484238642-10674-2-git-send-email-jglisse@redhat.com>
 <20170113135741.GA26827@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170113135741.GA26827@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Russell King <linux@armlinux.org.uk>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

On Fri, Jan 13, 2017 at 07:27:41PM +0530, Balbir Singh wrote:
> On Thu, Jan 12, 2017 at 11:30:28AM -0500, Jerome Glisse wrote:
> > When hotpluging memory we want more informations on the type of memory and
> > its properties. Replace the device boolean flag by an int and define a set
> > of flags.
> > 
> > New property for device memory is an opt-in flag to allow page migration
> > from and to a ZONE_DEVICE. Existing user of ZONE_DEVICE are not expecting
> > page migration to work for their pages. New changes to page migration i
> > changing that and we now need a flag to explicitly opt-in page migration.
> 
> Given that ZONE_DEVICE is dependent on X86_64, do we need to touch all
> architectures? I guess we could selectively enable things as we enable
> ZONE_DEVICE for other architectures?

Yes i need to change all architecture because the function prototype changes.

I add the bug stuff to be bullet proof from new feature added that might
cause trouble if arch does not handle them explicitly. If the bug stuff scares
people i can remove it.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
