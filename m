Received: by rv-out-0910.google.com with SMTP id f1so1806290rvb.26
        for <linux-mm@kvack.org>; Wed, 26 Mar 2008 12:28:28 -0700 (PDT)
Message-ID: <86802c440803261228m5026bca1x46047c0dc656545c@mail.gmail.com>
Date: Wed, 26 Mar 2008 12:28:28 -0700
From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [PATCH 2/2] x86: Modify Kconfig to allow up to 4096 cpus
In-Reply-To: <20080326014138.292294000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080326014137.934171000@polaris-admin.engr.sgi.com>
	 <20080326014138.292294000@polaris-admin.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 25, 2008 at 6:41 PM, Mike Travis <travis@sgi.com> wrote:
> Increase the limit of NR_CPUS to 4096 and introduce a boolean
>  called "MAXSMP" which when set (e.g. "allyesconfig"), will set
>  NR_CPUS = 4096 and NODES_SHIFT = 9 (512).
>
>  Based on:
>         git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
>         git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git
>
>  Signed-off-by: Mike Travis <travis@sgi.com>
>  ---
>   arch/x86/Kconfig |   20 ++++++++++++++++----
>   1 file changed, 16 insertions(+), 4 deletions(-)
>
>  --- linux.trees.git.orig/arch/x86/Kconfig
>  +++ linux.trees.git/arch/x86/Kconfig
>  @@ -522,16 +522,24 @@ config SWIOTLB
>           access 32-bits of memory can be used on systems with more than
>           3 GB of memory. If unsure, say Y.
>
>  +config MAXSMP
>  +       bool "Configure Maximum number of SMP Processors"
>  +       depends on X86_64 && SMP
>  +       default n
>  +       help
>  +         Configure maximum number of CPUS for this architecture.
>  +         If unsure, say N.
>
>   config NR_CPUS
>  -       int "Maximum number of CPUs (2-255)"
>  -       range 2 255
>  +       int "Maximum number of CPUs (2-4096)"
>  +       range 2 4096
>         depends on SMP
>  +       default "4096" if MAXSMP
>         default "32" if X86_NUMAQ || X86_SUMMIT || X86_BIGSMP || X86_ES7000
>         default "8"
>         help
>           This allows you to specify the maximum number of CPUs which this
>  -         kernel will support.  The maximum supported value is 255 and the
>  +         kernel will support.  The maximum supported value is 4096 and the
>           minimum value which makes sense is 2.
>
>           This is purely to save memory - each supported CPU adds

or put
if  MAXSMP around NR_CPUS...

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
