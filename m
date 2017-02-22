From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v4 07/28] x86: Provide general kernel support for
 memory encryption
Date: Wed, 22 Feb 2017 13:08:03 +0100
Message-ID: <20170222120802.ke3wvs3ixa72fj2l@pd.tnic>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154332.19244.55451.stgit@tlendack-t1.amdoffice.net>
 <20170220152152.apdfjjuvu2u56tik@pd.tnic>
 <78e1d42a-3a7b-2508-28d6-38a9d45a1c55@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <78e1d42a-3a7b-2508-28d6-38a9d45a1c55@amd.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>
List-Id: linux-mm.kvack.org

On Tue, Feb 21, 2017 at 11:18:08AM -0600, Tom Lendacky wrote:
> It's the latter.  It's really only used for working with values that
> will either be written to or read from cr3.  I'll add some comments
> around the macros as well as expand on it in the commit message.

Ok, that makes sense. Normally we will have the mask in the lower levels
of the pagetable hierarchy but we need to add it to the CR3 value by
hand. Yap.

> Ok, I'll try and come up with something...  maybe __sme_rm or
> __sme_clear (__sme_clr).

__sme_clr looks nice to me :)

Thanks.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
