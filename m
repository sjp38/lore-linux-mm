From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v2 14/16] x86, nvdimm, kexec: Use walk_iomem_res_desc()
 for iomem search
Date: Mon, 4 Jan 2016 20:41:00 +0100
Message-ID: <20160104194059.GM22941@pd.tnic>
References: <1451081365-15190-1-git-send-email-toshi.kani@hpe.com>
 <1451081365-15190-14-git-send-email-toshi.kani@hpe.com>
 <20151226103804.GB21988@pd.tnic>
 <567F315B.8080005@hpe.com>
 <20151227021257.GA13560@dhcp-128-25.nay.redhat.com>
 <20151227102406.GB19398@nazgul.tnic>
 <20160104092937.GB7033@dhcp-128-65.nay.redhat.com>
 <20160104122619.GH22941@pd.tnic>
 <1451930260.19330.21.camel@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1451930260.19330.21.camel@hpe.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Toshi Kani <toshi.kani@hpe.com>
Cc: Dave Young <dyoung@redhat.com>, Minfei Huang <mhuang@redhat.com>, linux-arch@vger.kernel.org, linux-nvdimm@ml01.01.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Dan Williams <dan.j.williams@intel.com>
List-Id: linux-mm.kvack.org

On Mon, Jan 04, 2016 at 10:57:40AM -0700, Toshi Kani wrote:
> With this change, there will be no caller to walk_iomem_res().  Should we
> remove walk_iomem_res() altogether, or keep it for now as a deprecated func
> with the checkpatch check?

Yes, kill it on the spot so that people don't get crazy ideas.

Thanks!

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
