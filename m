From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v2 12/20] x86: Add support for changing memory
 encryption attribute
Date: Mon, 12 Sep 2016 18:41:33 +0200
Message-ID: <20160912164132.zmqef4ozbggt5ovh@pd.tnic>
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
 <20160822223749.29880.10183.stgit@tlendack-t1.amdoffice.net>
 <20160909172314.ifcteua7nr52mzgs@pd.tnic>
 <4e423d15-7fe2-450a-05dd-1674bd281124@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4e423d15-7fe2-450a-05dd-1674bd281124@amd.com>
Sender: linux-arch-owner@vger.kernel.org
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.>
List-Id: linux-mm.kvack.org

On Mon, Sep 12, 2016 at 10:41:29AM -0500, Tom Lendacky wrote:
> Looking at __change_page_attr_set_clr() isn't it possible for some of
> the pages to be changed before an error is encountered since it is
> looping?  If so, we may still need to flush. The CPA_FLUSHTLB flag
> should take care of a failing case where no attributes have actually
> been changed.

Ah, yes, ok, then yours is correct.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
