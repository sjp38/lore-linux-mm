Received: by wa-out-1112.google.com with SMTP id m33so2375449wag
        for <linux-mm@kvack.org>; Mon, 18 Jun 2007 11:58:54 -0700 (PDT)
Message-ID: <6bffcb0e0706181158l739864e0t6fb5bc564444f23c@mail.gmail.com>
Date: Mon, 18 Jun 2007 20:58:54 +0200
From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: [patch 00/26] Current slab allocator / SLUB patch queue
In-Reply-To: <Pine.LNX.4.64.0706181102280.6596@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070618095838.238615343@sgi.com>
	 <46767346.2040108@googlemail.com>
	 <Pine.LNX.4.64.0706180936280.4751@schroedinger.engr.sgi.com>
	 <6bffcb0e0706181038j107e2357o89c525261cf671a@mail.gmail.com>
	 <Pine.LNX.4.64.0706181102280.6596@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On 18/06/07, Christoph Lameter <clameter@sgi.com> wrote:
> On Mon, 18 Jun 2007, Michal Piotrowski wrote:
>
> > > Does this patch fix the issue?
> > Unfortunately no.
> >
> > AFAIR I didn't see it in 2.6.22-rc4-mm2
>
> Seems that I miscounted. We need a larger safe area.
>

Still the same.

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
