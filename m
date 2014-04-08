Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3961C6B00A7
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 09:26:49 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d17so692607eek.32
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 06:26:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id g47si2786350eet.234.2014.04.08.06.26.42
        for <linux-mm@kvack.org>;
        Tue, 08 Apr 2014 06:26:43 -0700 (PDT)
Message-ID: <5343F2EC.3050508@redhat.com>
Date: Tue, 08 Apr 2014 15:00:28 +0200
From: Florian Weimer <fweimer@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
In-Reply-To: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <matthew@wil.cx>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, =?ISO-8859-1?Q?Kristian_H=F8gsberg?= <krh@bitplanet.net>, john.stultz@linaro.org, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, dri-devel@lists.freedesktop.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>

On 03/19/2014 08:06 PM, David Herrmann wrote:

> Unlike existing techniques that provide similar protection, sealing allows
> file-sharing without any trust-relationship. This is enforced by rejecting seal
> modifications if you don't own an exclusive reference to the given file. So if
> you own a file-descriptor, you can be sure that no-one besides you can modify
> the seals on the given file. This allows mapping shared files from untrusted
> parties without the fear of the file getting truncated or modified by an
> attacker.

How do you keep these promises on network and FUSE file systems?  Surely 
there is still some trust involved for such descriptors?

What happens if you create a loop device on a sealed descriptor?

Why does memfd_create not create a file backed by a memory region in the 
current process?  Wouldn't this be a far more generic primitive? 
Creating aliases of memory regions would be interesting for many things 
(not just libffi bypassing SELinux-enforced NX restrictions :-).

-- 
Florian Weimer / Red Hat Product Security Team

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
