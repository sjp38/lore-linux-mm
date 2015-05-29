From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v10 11/12] x86, mm, pat: Refactor !pat_enabled handling
Date: Fri, 29 May 2015 17:13:08 +0200
Message-ID: <20150529151308.GG31435@pd.tnic>
References: <1432739944-22633-1-git-send-email-toshi.kani@hp.com>
 <1432739944-22633-12-git-send-email-toshi.kani@hp.com>
 <20150529085842.GA31435@pd.tnic>
 <1432909628.23540.40.camel@misato.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1432909628.23540.40.camel@misato.fc.hp.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de
List-Id: linux-mm.kvack.org

On Fri, May 29, 2015 at 08:27:08AM -0600, Toshi Kani wrote:
> This simply preserves the original error check in the code.  This error
> check makes sure that all CPUs have the PAT feature supported when PAT
> is enabled.  This error can only happen when heterogeneous CPUs are
> installed/emulated on the system/guest.  This check may be paranoid, but
> this cleanup is not meant to modify such an error check.

No, this is a ridiculous attempt to justify crazy code. Please do it
right. If the cleanup makes the code more insane than it is, then don't
do it in the first place.

> Can you consider the patch 10/12-11/12 as a separate patchset from the
> WT series?  If that is OK, I will resubmit 10/12 (BUG->panic) and 11/12
> (commit log update).

That's not enough. 11/12 is a convoluted mess which needs splitting and
more detailed explanations in the commit messages.

So no. Read what I said: do the cleanup *first* , *then* add the new
functionality.

The WT patches shouldn't change all too much from what you have now.
Also, 11/12 changes stuff which you add in 1/12. This churn is useless
and shouldn't be there at all.

So you should be able to do the cleanup first and have the WT stuff
ontop just fine.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--
