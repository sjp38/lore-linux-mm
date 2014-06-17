Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9799D6B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 05:48:39 -0400 (EDT)
Received: by mail-we0-f172.google.com with SMTP id u57so7000425wes.3
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 02:48:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id fi1si11826013wib.88.2014.06.17.02.48.37
        for <linux-mm@kvack.org>;
        Tue, 17 Jun 2014 02:48:38 -0700 (PDT)
Message-ID: <53A00EDB.3050108@redhat.com>
Date: Tue, 17 Jun 2014 11:48:11 +0200
From: Florian Weimer <fweimer@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com> <20140320153250.GC20618@thunk.org> <CANq1E4SUXrzAV8FS8HVYxnRVb1oOR6HSTyucJzyFs5PuS5Y88A@mail.gmail.com> <20140320163806.GA10440@thunk.org> <5346ED93.9040500@amacapital.net> <20140410203246.GB31614@thunk.org> <CALCETrVmaGNCxo-L4-dPbUev3VXXEPR7xBzo3Fux6ny7yh_Gzw@mail.gmail.com>
In-Reply-To: <CALCETrVmaGNCxo-L4-dPbUev3VXXEPR7xBzo3Fux6ny7yh_Gzw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Theodore Ts'o <tytso@mit.edu>, David Herrmann <dh.herrmann@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, John Stultz <john.stultz@linaro.org>, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>

On 04/10/2014 10:37 PM, Andy Lutomirski wrote:

> It occurs to me that, before going nuts with these kinds of flags, it
> may pay to just try to fix the /proc/self/fd issue for real -- we
> could just make open("/proc/self/fd/3", O_RDWR) fail if fd 3 is
> read-only.  That may be enough for the file sealing thing.

Increasing privilege on O_PATH descriptors via access through 
/proc/self/fd is part of the userspace API.  The same thing might be 
true for O_RDONLY descriptors, but it's a bit less likely that there are 
any users out there.  In any case, I'm not sure it makes sense to plug 
the O_RDONLY hole while leaving the O_PATH hole open.

-- 
Florian Weimer / Red Hat Product Security Team

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
