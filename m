From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v2 14/16] x86,nvdimm,kexec: Use walk_iomem_res_desc() for
 iomem search
Date: Sat, 26 Dec 2015 11:38:04 +0100
Message-ID: <20151226103804.GB21988@pd.tnic>
References: <1451081365-15190-1-git-send-email-toshi.kani@hpe.com>
 <1451081365-15190-14-git-send-email-toshi.kani@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1451081365-15190-14-git-send-email-toshi.kani@hpe.com>
Sender: linux-arch-owner@vger.kernel.org
To: Toshi Kani <toshi.kani@hpe.com>
Cc: akpm@linux-foundation.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Dave Young <dyoung@redhat.com>, x86@kernel.org, linux-nvdimm@lists.01.org
List-Id: linux-mm.kvack.org

On Fri, Dec 25, 2015 at 03:09:23PM -0700, Toshi Kani wrote:
> Change to call walk_iomem_res_desc() for searching resource entries
> with the following names:
>  "ACPI Tables"
>  "ACPI Non-volatile Storage"
>  "Persistent Memory (legacy)"
>  "Crash kernel"
> 
> Note, the caller of walk_iomem_res() with "GART" is left unchanged
> because this entry may be initialized by out-of-tree drivers, which
> do not have 'desc' set to IORES_DESC_GART.

There's this out-of-tree bogus argument again. :\

Why do we care about out-of-tree drivers?

You can just as well fix the "GART" case too and kill walk_iomem_res()
altogether...

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
