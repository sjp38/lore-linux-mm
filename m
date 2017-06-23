Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 876E96B0279
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 15:20:27 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id g86so47568680iod.14
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 12:20:27 -0700 (PDT)
Received: from mail-it0-x22a.google.com (mail-it0-x22a.google.com. [2607:f8b0:4001:c0b::22a])
        by mx.google.com with ESMTPS id d197si4707228itc.51.2017.06.23.12.20.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 12:20:26 -0700 (PDT)
Received: by mail-it0-x22a.google.com with SMTP id b205so13031593itg.1
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 12:20:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170623140651.GD5314@dhcp22.suse.cz>
References: <20170620230911.GA25238@beast> <20170623140651.GD5314@dhcp22.suse.cz>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 23 Jun 2017 12:20:25 -0700
Message-ID: <CAGXu5jJ8SD8hsMDfZ9qJHQbJ3iSTXTq81PpiG+kbnXwx=akDKg@mail.gmail.com>
Subject: Re: [PATCH v2] mm: Allow slab_nomerge to be set at build time
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Jonathan Corbet <corbet@lwn.net>, Daniel Micay <danielmicay@gmail.com>, David Windsor <dave@nullcore.net>, Eric Biggers <ebiggers3@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Mauro Carvalho Chehab <mchehab@kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Tejun Heo <tj@kernel.org>, Daniel Mack <daniel@zonque.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Helge Deller <deller@gmx.de>, Rik van Riel <riel@redhat.com>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jun 23, 2017 at 7:06 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Tue 20-06-17 16:09:11, Kees Cook wrote:
>> Some hardened environments want to build kernels with slab_nomerge
>> already set (so that they do not depend on remembering to set the kernel
>> command line option). This is desired to reduce the risk of kernel heap
>> overflows being able to overwrite objects from merged caches and changes
>> the requirements for cache layout control, increasing the difficulty of
>> these attacks. By keeping caches unmerged, these kinds of exploits can
>> usually only damage objects in the same cache (though the risk to metadata
>> exploitation is unchanged).
>
> Do we really want to have a dedicated config for each hardening specific
> kernel command line? I believe we have quite a lot of config options
> already. Can we rather have a CONFIG_HARDENED_CMD_OPIONS and cover all
> those defauls there instead?

There's not been a lot of success with grouped Kconfigs in the past
(e.g. CONFIG_EXPERIMENTAL), but one thing that has been suggested is a
defconfig-like make target that would collect all the things together.
I haven't had time for that, but that would let us group the various
configs.

Additionally, using something like CONFIG_CMDLINE seems a little clunky to me.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
