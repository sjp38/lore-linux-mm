Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1B5146B0007
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 07:09:43 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v14so486185pgq.11
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 04:09:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d16-v6si947151plr.141.2018.04.11.04.09.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Apr 2018 04:09:41 -0700 (PDT)
Date: Wed, 11 Apr 2018 13:09:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 2/2] mm: remove odd HAVE_PTE_SPECIAL
Message-ID: <20180411110936.GG23400@dhcp22.suse.cz>
References: <1523433816-14460-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1523433816-14460-3-git-send-email-ldufour@linux.vnet.ibm.com>
 <de6ee514-8b7e-24d0-a7ee-a8887e8b0ae9@c-s.fr>
 <93ed4fe4-dd1e-51be-948b-d53b16de21c5@linux.vnet.ibm.com>
 <278a5212-b962-9a3a-cc86-76cac744afab@c-s.fr>
 <32655c37-91cb-17aa-58e7-74254e2673a0@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <32655c37-91cb-17aa-58e7-74254e2673a0@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Christophe LEROY <christophe.leroy@c-s.fr>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Jerome Glisse <jglisse@redhat.com>, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Vineet Gupta <vgupta@synopsys.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <albert@sifive.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, David Rientjes <rientjes@google.com>, Robin Murphy <robin.murphy@arm.com>

On Wed 11-04-18 12:32:07, Laurent Dufour wrote:
[...]
> Andrew, should I send a v4 or could you wipe the 2 __maybe_unsued when applying
> the patch ?

A follow $patch-fix should be better rather than post this again and
spam people with more emails.
-- 
Michal Hocko
SUSE Labs
