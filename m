From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v11 2/12] x86, mm, pat: Refactor !pat_enabled handling
Date: Sun, 31 May 2015 11:46:55 +0200
Message-ID: <20150531094655.GA20440@pd.tnic>
References: <1432940350-1802-1-git-send-email-toshi.kani@hp.com>
 <1432940350-1802-3-git-send-email-toshi.kani@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1432940350-1802-3-git-send-email-toshi.kani@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de
List-Id: linux-mm.kvack.org

On Fri, May 29, 2015 at 04:59:00PM -0600, Toshi Kani wrote:
> From: Toshi Kani <toshi.kani@hp.com>
> 
> This patch refactors the !pat_enabled code paths and integrates
> them into the PAT abstraction code.  The PAT table is emulated by
> corresponding to the two cache attribute bits, PWT (Write Through)
> and PCD (Cache Disable).  The emulated PAT table is the same as the
> BIOS default setup when the system has PAT but the "nopat" boot
> option is specified.  The emulated PAT table is also used when
> MSR_IA32_CR_PAT returns 0 -- 9d34cfdf4796 ("x86: Don't rely on
> VMWare emulating PAT MSR correctly").

To be honest, I wasn't surprised when you sent me the same patch and
ignored most of my comments. For the future, please let me know if I'm
wasting my time with commenting on your stuff so that I can plan my work
and not waste time and energy reviewing, ok?

Unfortunately, if you want something done right, you have to do it
yourself.

So I did that, I split that ugly cleanup into something much more
readable, patches as a reply to this message.

Feel free to base your work ontop of

git://git.kernel.org/pub/scm/linux/kernel/git/bp/bp.git#tip-mm-2

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--
