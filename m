Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id AA2226B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:01:01 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 77so211627wmm.13
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 02:01:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 74si10731294wmy.80.2017.06.26.02.00.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Jun 2017 02:01:00 -0700 (PDT)
Date: Mon, 26 Jun 2017 11:00:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: Allow slab_nomerge to be set at build time
Message-ID: <20170626090054.GF11534@dhcp22.suse.cz>
References: <20170620230911.GA25238@beast>
 <20170623140651.GD5314@dhcp22.suse.cz>
 <CAGXu5jJ8SD8hsMDfZ9qJHQbJ3iSTXTq81PpiG+kbnXwx=akDKg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jJ8SD8hsMDfZ9qJHQbJ3iSTXTq81PpiG+kbnXwx=akDKg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Christoph Lameter <cl@linux.com>, Jonathan Corbet <corbet@lwn.net>, Daniel Micay <danielmicay@gmail.com>, David Windsor <dave@nullcore.net>, Eric Biggers <ebiggers3@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Mauro Carvalho Chehab <mchehab@kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Tejun Heo <tj@kernel.org>, Daniel Mack <daniel@zonque.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Helge Deller <deller@gmx.de>, Rik van Riel <riel@redhat.com>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 23-06-17 12:20:25, Kees Cook wrote:
> On Fri, Jun 23, 2017 at 7:06 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Tue 20-06-17 16:09:11, Kees Cook wrote:
> >> Some hardened environments want to build kernels with slab_nomerge
> >> already set (so that they do not depend on remembering to set the kernel
> >> command line option). This is desired to reduce the risk of kernel heap
> >> overflows being able to overwrite objects from merged caches and changes
> >> the requirements for cache layout control, increasing the difficulty of
> >> these attacks. By keeping caches unmerged, these kinds of exploits can
> >> usually only damage objects in the same cache (though the risk to metadata
> >> exploitation is unchanged).
> >
> > Do we really want to have a dedicated config for each hardening specific
> > kernel command line? I believe we have quite a lot of config options
> > already. Can we rather have a CONFIG_HARDENED_CMD_OPIONS and cover all
> > those defauls there instead?
> 
> There's not been a lot of success with grouped Kconfigs in the past
> (e.g. CONFIG_EXPERIMENTAL), but one thing that has been suggested is a
> defconfig-like make target that would collect all the things together.

Which wouldn't reduce the number of config options, would it? I don't
know but is there any usecase when somebody wants to have hardened
kernel and still want to have different defaults than you are
suggesting?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
