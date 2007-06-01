Date: Fri, 1 Jun 2007 11:25:49 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 1/4] CONFIG_STABLE: Define it
In-Reply-To: <20070601180807.GB7968@redhat.com>
Message-ID: <Pine.LNX.4.64.0706011115120.2284@schroedinger.engr.sgi.com>
References: <20070531002047.702473071@sgi.com> <20070531003012.302019683@sgi.com>
 <a8e1da0705301735r5619f79axcb3ea6c7dd344efc@mail.gmail.com>
 <Pine.LNX.4.64.0705301747370.4809@schroedinger.engr.sgi.com>
 <20070601180807.GB7968@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: young dave <hidave.darkstar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 1 Jun 2007, Dave Jones wrote:

>  > Disabling SLUB_DEBUG should only be done for embedded systems. That is why 
>  > the option is in CONFIG_EMBEDDED.
> 
> Something I'd really love to have is a CONFIG option to decide if
> slub_debug is set or not by default.  The reasoning behind this is that during
> development of each Fedora release, I used to leave SLAB_DEBUG=y for
> months on end and catch all kinds of nasties.

So slub_debug as a boot parameter is not enough.

> Now that I've switched it over to using slub, I ended up adding the
> ugly patch below, because otherwise, no-one would ever run with
> slub_debug and we'd miss out on all those lovely bugs.

Oh. No worry. By default slub puts its free pointer in the most dangerous 
area. In my experience it will bug immediately if there is something 
wrong. The mode of operations that I had in mind for development was to 
run until we crash somewhere. Then reboot with slub_debug to get the 
lovely report on who did it.

> (I have 'make release' and 'make debug' targets which enable/disable
>  this [and other] patches in the Fedora kernel).
> 
> (Patch for illustration only, obviously not for applying).

Hummm..... I need to think about this one.
 
> Unless someone beats me to it, I'll hack up a CONFIG option around
> this. Having that turned on if !CONFIG_STABLE would also be a win I think.

Doing so will impair performance testing. Memory use will be changed due 
to the growth of all the objects etc etc. Generally I think running 
with slub_debug by default is overkill. 

Having said that you can do even more if you would run

slabinfo -v

to validate object from cron. That way you can check up on all slab 
objects.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
