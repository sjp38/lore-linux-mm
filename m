From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v2 2/3] x86/mm: Add a noinvpcid option to turn off INVPCID
Date: Fri, 29 Jan 2016 12:21:07 +0100
Message-ID: <20160129112106.GC10187@pd.tnic>
References: <cover.1453746505.git.luto@kernel.org>
 <321b1dde2b4341df44a7c408381c83905aa1762c.1453746505.git.luto@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <321b1dde2b4341df44a7c408381c83905aa1762c.1453746505.git.luto@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>
List-Id: linux-mm.kvack.org

On Mon, Jan 25, 2016 at 10:37:43AM -0800, Andy Lutomirski wrote:

<--- Commit message please, albeit a trivial one like "Add a chicken bit ..."

> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
>  Documentation/kernel-parameters.txt |  2 ++
>  arch/x86/kernel/cpu/common.c        | 16 ++++++++++++++++
>  2 files changed, 18 insertions(+)

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
