From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 2/4] x86/pat: Merge pat_init_cache_modes() into its caller
Date: Sun, 31 May 2015 12:24:55 +0200
Message-ID: <20150531102455.GC20440@pd.tnic>
References: <20150531094655.GA20440@pd.tnic>
 <1433065686-20922-1-git-send-email-bp@alien8.de>
 <1433065686-20922-2-git-send-email-bp@alien8.de>
 <556ADF39.4080709@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <556ADF39.4080709@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Juergen Gross <jgross@suse.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, arnd@arndb.de, Elliott@hp.com, hch@lst.de, hmh@hmh.eng.br, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, konrad.wilk@oracle.com, linux-mm <linux-mm@kvack.org>, linux-nvdimm@lists.01.org, "Luis R. Rodriguez" <mcgrof@suse.com>, stefan.bader@canonical.com, Thomas Gleixner <tglx@linutronix.de>, Toshi Kani <toshi.kani@hp.com>, x86-ml <x86@kernel.org>, yigal@plexistor.com
List-Id: linux-mm.kvack.org

On Sun, May 31, 2015 at 12:15:21PM +0200, Juergen Gross wrote:
> You are breaking the Xen build with that change. pat_init_cache_modes()
> is called from arch/x86/xen/enlighten.c as well.

Yeah, build-robot just caught that. Can you please check the enlighten.c
change in the other mail I just sent?

Thanks.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--
