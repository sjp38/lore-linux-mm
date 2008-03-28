Date: Fri, 28 Mar 2008 07:17:50 -0600
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: down_spin() implementation
Message-ID: <20080328131750.GT16721@parisc-linux.org>
References: <1FE6DD409037234FAB833C420AA843ECE9DF60@orsmsx424.amr.corp.intel.com> <20080326123239.GG16721@parisc-linux.org> <1FE6DD409037234FAB833C420AA843ECE9EB1C@orsmsx424.amr.corp.intel.com> <20080327141508.GL16721@parisc-linux.org> <20080328125104.GK12346@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080328125104.GK12346@kernel.dk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <jens.axboe@oracle.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 28, 2008 at 01:51:04PM +0100, Jens Axboe wrote:
> It used to be illegal to pass flags as parameters. IIRC, sparc did some
> trickery with it. That may still be the case, I haven't checked in a
> long time.

That problem was removed before 2.6 started, iirc.  At least the chapter
on 'The Fucked Up Sparc' [1] was removed before 2.6.12-rc2 (the
beginning of git history and I can't be bothered to pinpoint it more
precisely).

> Why not just fold __down_spin() into down_spin() and get rid of that
> nasty anyway?

Could have done.  It's moot now that Nick's pointed out how unsafe it
is to mix down_spin() with plain down().

[1] http://www.kernel.org/pub/linux/kernel/people/rusty/kernel-locking/x467.html

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
