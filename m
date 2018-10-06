Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id E12A96B000A
	for <linux-mm@kvack.org>; Sat,  6 Oct 2018 06:49:56 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id h82-v6so5442512ljh.16
        for <linux-mm@kvack.org>; Sat, 06 Oct 2018 03:49:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m67-v6sor5943782lje.13.2018.10.06.03.49.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 06 Oct 2018 03:49:54 -0700 (PDT)
MIME-Version: 1.0
References: <20181003185854.GA1174@jordon-HP-15-Notebook-PC>
 <20181003200003.GA9965@bombadil.infradead.org> <20181003221444.GZ30658@n2100.armlinux.org.uk>
 <CAFqt6zYHhmPwUdaCZX-BuAvaVwA-x1W39tz+Q50-nbEaW2cYVg@mail.gmail.com>
 <20181004123400.GC30658@n2100.armlinux.org.uk> <CAFqt6zZPOM17QwmcWKF3F1gqkJm=2PxvuJ3naWuRXZGHc2HrEQ@mail.gmail.com>
 <20181004181736.GB20842@bombadil.infradead.org> <CAFqt6zaN0PQHkjuwFf8VriROLy7qrPDu-iNE=VPiXJw8C7GpQg@mail.gmail.com>
 <CANiq72mkTP_m20vqei-cpN+ypQ_gU472qn5m68vb_4Nqj5afMQ@mail.gmail.com>
 <CAFqt6zaFc_GenhfvsD0VPfepR-jjXypj+4CgNEuHMVq1WXV+8w@mail.gmail.com>
 <CANiq72kVJn7985EET067Dgj+z0dwb0x2MTUnREMWKCVU6=WnJA@mail.gmail.com>
 <CAFqt6zZ4sPjtb5BaDfwc5tZv+vMj6ao3NJZ_3quX9AH5pCMwJg@mail.gmail.com>
 <CANiq72m9u1PL9X+dPNLxgkhvttj=4ijLyM2sFex=Kws7wswKzw@mail.gmail.com>
 <CAFqt6zYH4Aczu8AYke8AfGuMS70SJXCMn-n8X8C_Tz03gTjn8g@mail.gmail.com>
 <CANiq72kRAZE9SyM4EkpaBZH03Ex0Z=4Pk2iOuc2jBDKTfKjHQg@mail.gmail.com> <CAFqt6zZCCPFE3sQ3u_gjiN8wwd99nwWatk9JRsiGxbCwhi91mg@mail.gmail.com>
In-Reply-To: <CAFqt6zZCCPFE3sQ3u_gjiN8wwd99nwWatk9JRsiGxbCwhi91mg@mail.gmail.com>
From: Miguel Ojeda <miguel.ojeda.sandonis@gmail.com>
Date: Sat, 6 Oct 2018 12:49:42 +0200
Message-ID: <CANiq72k-e_j67==VdrayqggjAd7MAfpaJS-_0=jkmh4OWynukQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm: Introduce new function vm_insert_kmem_page
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux@armlinux.org.uk, Robin van der Gracht <robin@protonic.nl>, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, =?UTF-8?Q?Heiko_St=C3=BCbner?= <heiko@sntech.de>, Dave Airlie <airlied@linux.ie>, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Kees Cook <keescook@chromium.org>, treding@nvidia.com, mhocko@suse.com, Dan Williams <dan.j.williams@intel.com>, kirill.shutemov@linux.intel.com, Mark Rutland <mark.rutland@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitry Vyukov <dvyukov@google.com>, Kate Stewart <kstewart@linuxfoundation.org>, tchibo@google.com, riel@redhat.com, minchan@kernel.org, Peter Zijlstra <peterz@infradead.org>, ying.huang@intel.com, Andi Kleen <ak@linux.intel.com>, rppt@linux.vnet.ibm.com, Dominik Brodowski <linux@dominikbrodowski.net>, Arnd Bergmann <arnd@arndb.de>, cpandya@codeaurora.org, hannes@cmpxchg.org, Joe Perches <joe@perches.com>, mcgrof@kernel.org, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, Linux-MM <linux-mm@kvack.org>

On Sat, Oct 6, 2018 at 7:11 AM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> On Fri, Oct 5, 2018 at 11:39 PM Miguel Ojeda
> <miguel.ojeda.sandonis@gmail.com> wrote:
> > They are not supposed to be "steps". You did it with 70+ commits (!!)
> > over the course of several months. Why a tree wasn't created, stuff
> > developed there, and when done, submitted it for review?
>
> Because we already have a plan for entire vm_fault_t migration and
> the * instruction * was to send one patch per driver.

The instruction?

> >
> > Fine, but you haven't answered to the other parts of my email: you
> > don't explain why you choose one alternative over the others, you
> > simply keep changing the approach.
>
> We are going in circles here. That you want to convert vm_insert_page
> to vmf_insert_page for the PF case is fine and understood. However,
> you don't *need* to introduce a new name for the remaining non-PF
> cases if the function is going to be the exact same thing as before.
> You say "The final goal is to remove vm_insert_page", but you haven't
> justified *why* you need to remove that name.
>
> I think I have given that answer. If we don't remove vm_insert_page,
> future #PF caller will have option to use it. But those should be
> restricted. How are we going to restrict vm_insert_page in one half
> of kernel when other half is still using it  ?? Is there any way ? ( I don't
> know)

Ah, so that is what you are concerned about: future misuses. Well, I
don't really see the problem. There are only ~18 calls to
vm_insert_page() in the entire kernel: checking if people is using it
properly for a while should be easy. As long as the new behavior is
documented properly, it should be fine. If you are really concerned
about mistakes being made, then fine, we can rename it as I suggested.

Now, the new vm_insert_range() is another topic. It simplifies a few
of the callers and buys us the rename at the same time, so I am also
OK with it.

As you see, I am not against the changes -- it is just that they
should clearly justified. :-) It wasn't clear what your problem with
the current vm_insert_page() is.

Cheers,
Miguel
