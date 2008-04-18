Date: Thu, 17 Apr 2008 17:04:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.25-mm1: not looking good
Message-Id: <20080417170407.1e68dfc8.akpm@linux-foundation.org>
In-Reply-To: <200804171955.46600.paul.moore@hp.com>
References: <20080417160331.b4729f0c.akpm@linux-foundation.org>
	<200804171955.46600.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Moore <paul.moore@hp.com>
Cc: mingo@elte.hu, tglx@linutronix.de, penberg@cs.helsinki.fi, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jmorris@namei.org, sds@tycho.nsa.gov
List-ID: <linux-mm.kvack.org>

On Thu, 17 Apr 2008 19:55:46 -0400
Paul Moore <paul.moore@hp.com> wrote:

> For what it's worth I just looked over the changes in netnode.c and 
> nothing is jumping out at me.  The changes ran fine for me when tested 
> on the later 2.6.25-rcX kernels but I suppose that doesn't mean a whole 
> lot.

Perhaps it was tested only against slub?  That config uses slab.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
