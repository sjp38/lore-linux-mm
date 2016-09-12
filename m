From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v2 10/20] x86: Insure that memory areas are encrypted
 when possible
Date: Mon, 12 Sep 2016 18:33:49 +0200
Message-ID: <20160912163349.exnuvr7svsq7fmui@pd.tnic>
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
 <20160822223722.29880.94331.stgit@tlendack-t1.amdoffice.net>
 <20160909155305.bmm2fvw7ndjjhqvo@pd.tnic>
 <23855fb4-05b0-4c12-d34f-4d5f45f3b015@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <23855fb4-05b0-4c12-d34f-4d5f45f3b015@amd.com>
Sender: linux-arch-owner@vger.kernel.org
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.>
List-Id: linux-mm.kvack.org

On Mon, Sep 12, 2016 at 10:05:36AM -0500, Tom Lendacky wrote:
> I can look into that.  The reason I put this here is this is all the
> early page fault support that is very specific to this file. I modified
> an existing static function to take advantage of the mapping support.

Yeah, but all this code is SME-specific and doesn't belong there.
AFAICT, it uses global/public symbols so there shouldn't be a problem to
have it in mem_encrypt.c.

> Hmmm, maybe... With the change to the early_memremap() the initrd is now
> identified as BOOT_DATA in relocate_initrd() and so it will be mapped
> and copied as non-encyrpted data. But since it was encrypted before the
> call to relocate_initrd() it will copy encrypted bytes which will later
> be accessed encrypted. That isn't clear though, so I'll rework
> reserve_initrd() to perform the sme_early_mem_enc() once at the end
> whether the initrd is re-located or not.

Makes sense.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
