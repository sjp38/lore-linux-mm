Date: Fri, 3 Oct 2008 10:02:44 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] x86_64: Implement personality ADDR_LIMIT_32BIT
Message-ID: <20081003080244.GC25408@elte.hu>
References: <1223017469-5158-1-git-send-email-kirill@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1223017469-5158-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* Kirill A. Shutemov <kirill@shutemov.name> wrote:

> -	/* for MAP_32BIT mappings we force the legact mmap base */
> -	if (!test_thread_flag(TIF_IA32) && (flags & MAP_32BIT))
> +	/* for MAP_32BIT mappings and ADDR_LIMIT_32BIT personality we force the
> +	 * legact mmap base
> +	 */

please use the customary multi-line comment style:

  /*
   * Comment .....
   * ...... goes here:
   */

and you might use the opportunity to fix the s/legact/legacy typo as 
well.

but more generally, we already have ADDR_LIMIT_3GB support on x86. Why 
should support for ADDR_LIMIT_32BIT be added?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
