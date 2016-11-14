From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v3 06/20] x86: Add support to enable SME during early
 boot processing
Date: Mon, 14 Nov 2016 21:01:32 +0100
Message-ID: <20161114200132.i54uar3wckqlzsbt@pd.tnic>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003543.3280.99623.stgit@tlendack-t1.amdoffice.net>
 <20161114172930.27z7p2kytmhtcbsb@pd.tnic>
 <178d7d21-ffbd-1083-9c64-f05378147e27@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <178d7d21-ffbd-1083-9c64-f05378147e27@amd.com>
Sender: kvm-owner@vger.kernel.org
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>
List-Id: linux-mm.kvack.org

On Mon, Nov 14, 2016 at 12:18:44PM -0600, Tom Lendacky wrote:
> The %rsi register can be clobbered by the called function so I'm saving
> it since it points to the real mode data.  I might be able to look into
> saving it earlier and restoring it before needed, but I though this
> might be clearer.

Ah, that's already in the comment earlier, I missed that.

> I can expand on the commit message about that.  I was trying to keep the
> early boot-related code separate from the main code in arch/x86/mm dir.

... because?

It all gets linked into one monolithic image anyway and mem_encrypt.c
is not, like, really huge, right? IOW, I don't see a reason to spread
the code around the tree. OTOH, having everything in one file is much
better.

Or am I missing a good reason?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
