Received: by nz-out-0506.google.com with SMTP id x7so1527075nzc
        for <linux-mm@kvack.org>; Mon, 18 Jun 2007 12:09:08 -0700 (PDT)
Message-ID: <6bffcb0e0706181209p49f4ae86xce5418b7c9b3edbb@mail.gmail.com>
Date: Mon, 18 Jun 2007 21:09:04 +0200
From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: [patch 00/26] Current slab allocator / SLUB patch queue
In-Reply-To: <Pine.LNX.4.64.0706181159430.1896@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070618095838.238615343@sgi.com>
	 <46767346.2040108@googlemail.com>
	 <Pine.LNX.4.64.0706180936280.4751@schroedinger.engr.sgi.com>
	 <6bffcb0e0706181038j107e2357o89c525261cf671a@mail.gmail.com>
	 <Pine.LNX.4.64.0706181102280.6596@schroedinger.engr.sgi.com>
	 <6bffcb0e0706181158l739864e0t6fb5bc564444f23c@mail.gmail.com>
	 <Pine.LNX.4.64.0706181159430.1896@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On 18/06/07, Christoph Lameter <clameter@sgi.com> wrote:
> On Mon, 18 Jun 2007, Michal Piotrowski wrote:
>
> > Still the same.
>
> Is it still exactly the same strack trace?

Not exactly the same
[<c0480d4b>] list_locations+0x257/0x2ad
is the only difference

 l *list_locations+0x257
0xc1080d4b is in list_locations (mm/slub.c:3655).
3650                                    l->min_pid);
3651
3652                    if (num_online_cpus() > 1 && !cpus_empty(l->cpus) &&
3653                                    n < PAGE_SIZE - n - 60) {
3654                            n += sprintf(buf + n, " cpus=");
3655                            n += cpulist_scnprintf(buf + n,
PAGE_SIZE - n - 50,
3656                                            l->cpus);
3657                    }
3658
3659                    if (num_online_nodes() > 1 && !nodes_empty(l->nodes) &&


> There could be multiple issue
> if we overflow PAGE_SIZE there.

Regards,
Michal

-- 
LOG
http://www.stardust.webpages.pl/log/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
