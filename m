Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id DDF6E6B0006
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 19:32:28 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id wy12so376122pbc.7
        for <linux-mm@kvack.org>; Tue, 12 Mar 2013 16:32:28 -0700 (PDT)
Message-ID: <513FBB07.9030508@gmail.com>
Date: Wed, 13 Mar 2013 07:32:23 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: security: restricting access to swap
References: <CAA25o9RchY2AD8U30bh4H+fz6kq8bs98SUrkJUkTpbTHSGjcGA@mail.gmail.com>
In-Reply-To: <CAA25o9RchY2AD8U30bh4H+fz6kq8bs98SUrkJUkTpbTHSGjcGA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

Cc experts Johannes, Hugh,
On 03/12/2013 07:57 AM, Luigi Semenzato wrote:
> Greetings linux-mmers,
>
> before we can fully deploy zram, we must ensure it conforms to the
> Chrome OS security requirements.  In particular, we do not want to
> allow user space to read/write the swap device---not even root-owned
> processes.
>
> A similar restriction is available for /dev/mem under CONFIG_STRICT_DEVMEM.
>
> There are a few possible approaches to this, but before we go ahead
> I'd like to ask if anything has happened or is planned in this
> direction.
>
> Otherwise, one idea I am playing with is to add a CONFIG_STRICT_SWAP
> option that would do this for any swap device (i.e. not specific to
> zram) and possibly also when swapping to a file.  We would add an
> "internal" open flag, O_KERN_SWAP, as well as clean up a little bit
> the FMODE_NONOTIFY confusion by adding the kernel flag O_KERN_NONOTIFY
> and formalizing the sets of external (O_*) and internal (O_KERN_*)
> open flags.
>
> Swapon() and swapoff() would use O_KERN_SWAP internally, and a device
> opened with that flag would reject user-level opens.
>
> Thank you in advance for any input/suggestion!
> Luigi
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
