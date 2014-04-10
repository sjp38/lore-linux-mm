Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id D6AEA6B0035
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 15:17:53 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rr13so4337066pbb.25
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 12:17:53 -0700 (PDT)
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
        by mx.google.com with ESMTPS id hi3si2730442pac.287.2014.04.10.12.17.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Apr 2014 12:17:52 -0700 (PDT)
Received: by mail-pb0-f53.google.com with SMTP id rp16so4303135pbb.26
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 12:17:52 -0700 (PDT)
Message-ID: <5346EE5D.2020503@amacapital.net>
Date: Thu, 10 Apr 2014 12:17:49 -0700
From: Andy Lutomirski <luto@amacapital.net>
MIME-Version: 1.0
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com> <5343F2EC.3050508@redhat.com>
In-Reply-To: <5343F2EC.3050508@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>, David Herrmann <dh.herrmann@gmail.com>, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <matthew@wil.cx>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, =?ISO-8859-1?Q?Kristian_H=F8gsberg?= <krh@bitplanet.net>, john.stultz@linaro.org, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, dri-devel@lists.freedesktop.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>

On 04/08/2014 06:00 AM, Florian Weimer wrote:
> On 03/19/2014 08:06 PM, David Herrmann wrote:
> 
>> Unlike existing techniques that provide similar protection, sealing
>> allows
>> file-sharing without any trust-relationship. This is enforced by
>> rejecting seal
>> modifications if you don't own an exclusive reference to the given
>> file. So if
>> you own a file-descriptor, you can be sure that no-one besides you can
>> modify
>> the seals on the given file. This allows mapping shared files from
>> untrusted
>> parties without the fear of the file getting truncated or modified by an
>> attacker.
> 
> How do you keep these promises on network and FUSE file systems?  Surely
> there is still some trust involved for such descriptors?
> 
> What happens if you create a loop device on a sealed descriptor?
> 
> Why does memfd_create not create a file backed by a memory region in the
> current process?  Wouldn't this be a far more generic primitive?
> Creating aliases of memory regions would be interesting for many things
> (not just libffi bypassing SELinux-enforced NX restrictions :-).

If you write a patch to prevent selinux from enforcing NX, I will ack
that patch with all my might.  I don't know how far it would get me, but
I think that selinux has no business going anywhere near execmem.

Adding a clone mode to mremap might be a better bet.  But memfd solves
that problem, too, albeit messily.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
