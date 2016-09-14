From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v2 15/20] iommu/amd: AMD IOMMU support for memory
 encryption
Date: Wed, 14 Sep 2016 16:41:39 +0200
Message-ID: <20160914144139.GA9295@nazgul.tnic>
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
 <20160822223820.29880.17752.stgit@tlendack-t1.amdoffice.net>
 <20160912114550.nwhtpmncwp22l7vy@pd.tnic>
 <27bc5c87-3a74-a1ee-55b1-7f19ec9cd6cc@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <27bc5c87-3a74-a1ee-55b1-7f19ec9cd6cc@amd.com>
Sender: linux-arch-owner@vger.kernel.org
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.>
List-Id: linux-mm.kvack.org

On Wed, Sep 14, 2016 at 08:45:44AM -0500, Tom Lendacky wrote:
> Currently, mem_encrypt.h only lives in the arch/x86 directory so it
> wouldn't be able to be included here without breaking other archs.

I'm wondering if it would be simpler to move only sme_me_mask to an
arch-agnostic header just so that we save us all the code duplication.

Hmmm.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--
