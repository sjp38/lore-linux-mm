Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 989A76B038E
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 16:08:34 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id h188so12899400wma.4
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 13:08:34 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id a15si20007853wra.327.2017.03.19.13.08.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 19 Mar 2017 13:08:33 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 8A3EC98D0A
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 20:08:32 +0000 (UTC)
Date: Sun, 19 Mar 2017 20:08:21 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [HMM 01/16] mm/memory/hotplug: convert device bool to int to
 allow for more flags v3
Message-ID: <20170319200821.GB2774@techsingularity.net>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
 <1489680335-6594-2-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1489680335-6594-2-git-send-email-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: J?r?me Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Russell King <linux@armlinux.org.uk>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

On Thu, Mar 16, 2017 at 12:05:20PM -0400, J?r?me Glisse wrote:
> When hotpluging memory we want more informations on the type of memory and
> its properties. Replace the device boolean flag by an int and define a set
> of flags.
> 
> New property for device memory is an opt-in flag to allow page migration
> from and to a ZONE_DEVICE. Existing user of ZONE_DEVICE are not expecting
> page migration to work for their pages. New changes to page migration i
> changing that and we now need a flag to explicitly opt-in page migration.
> 
> Changes since v2:
>   - pr_err() in case of hotplug failure
> 
> Changes since v1:
>   - Improved commit message
>   - Improved define name
>   - Improved comments
>   - Typos
> 
> Signed-off-by: Jerome Glisse <jglisse@redhat.com>

Fairly minor but it's standard for flags to be unsigned due to
uncertainity about what happens when a signed type is bit shifted.
May not apply to your case but fairly trivial to address.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
