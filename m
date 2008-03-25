Date: Tue, 25 Mar 2008 21:47:25 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: What if a TLB flush needed to sleep?
Message-ID: <20080325214725.3d707445@core>
In-Reply-To: <1FE6DD409037234FAB833C420AA843ECE9DF60@orsmsx424.amr.corp.intel.com>
References: <1FE6DD409037234FAB833C420AA843ECE9DF60@orsmsx424.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> 	down(&ptcg_sem);
> 	... execute ptc.g
> 	up(&ptcg_sem);

That will dig you a nice large hole for real time to fall into. If you
want to do rt nicely you want to avoid semaphores and the corresponding
lack of ability to fix priority inversions.

> 2) Is it feasible to rearrange the MM code so that we don't
> hold any locks while doing a TLB flush?  Or should I implement
> some sort of spin_only_semaphore?

Better to keep ia64 perversions in the IA64 code whenever possible and
lower risk for everyone else.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
