From: Paul Moore <paul.moore@hp.com>
Subject: Re: 2.6.25-mm1: not looking good
Date: Fri, 18 Apr 2008 10:55:53 -0400
References: <20080417160331.b4729f0c.akpm@linux-foundation.org> <200804171955.46600.paul.moore@hp.com> <20080417170407.1e68dfc8.akpm@linux-foundation.org>
In-Reply-To: <20080417170407.1e68dfc8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200804181055.53281.paul.moore@hp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mingo@elte.hu, tglx@linutronix.de, penberg@cs.helsinki.fi, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jmorris@namei.org, sds@tycho.nsa.gov
List-ID: <linux-mm.kvack.org>

On Thursday 17 April 2008 8:04:07 pm Andrew Morton wrote:
> On Thu, 17 Apr 2008 19:55:46 -0400
>
> Paul Moore <paul.moore@hp.com> wrote:
> > For what it's worth I just looked over the changes in netnode.c and
> > nothing is jumping out at me.  The changes ran fine for me when
> > tested on the later 2.6.25-rcX kernels but I suppose that doesn't
> > mean a whole lot.
>
> Perhaps it was tested only against slub?  That config uses slab.

Yes, I believe it was testing it with slub.

-- 
paul moore
linux @ hp

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
