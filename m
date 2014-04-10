Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 35A5C6B0035
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 19:05:58 -0400 (EDT)
Received: by mail-qc0-f174.google.com with SMTP id c9so5168540qcz.33
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 16:05:55 -0700 (PDT)
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
        by mx.google.com with ESMTPS id 100si2555453qgf.37.2014.04.10.16.05.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Apr 2014 16:05:55 -0700 (PDT)
Received: by mail-qc0-f171.google.com with SMTP id c9so5144469qcz.2
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 16:05:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CANq1E4Qa8N0G8whyW5OWQS4x9=CVOF0PpcLhDi4j3wGTHX0==w@mail.gmail.com>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
 <20140320153250.GC20618@thunk.org> <CANq1E4SUXrzAV8FS8HVYxnRVb1oOR6HSTyucJzyFs5PuS5Y88A@mail.gmail.com>
 <20140320163806.GA10440@thunk.org> <5346ED93.9040500@amacapital.net>
 <20140410203246.GB31614@thunk.org> <CALCETrVmaGNCxo-L4-dPbUev3VXXEPR7xBzo3Fux6ny7yh_Gzw@mail.gmail.com>
 <CANq1E4RofJ7CUWWBPW1Qb4pX3rxYHCh1CPtbtX241KtJO+=Qhw@mail.gmail.com>
 <CALCETrXVzLcVVSuPMFUgoRvpQgcQNy2_rW6=11CJAME0W2GyYQ@mail.gmail.com> <CANq1E4Qa8N0G8whyW5OWQS4x9=CVOF0PpcLhDi4j3wGTHX0==w@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 10 Apr 2014 16:05:34 -0700
Message-ID: <CALCETrXFJfoD9xrYpu6UjsHF74kYm3_o-xLNKjqh-OF2x-nyFQ@mail.gmail.com>
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: Theodore Ts'o <tytso@mit.edu>, linux-kernel <linux-kernel@vger.kernel.org>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, John Stultz <john.stultz@linaro.org>, Greg Kroah-Hartman <greg@kroah.com>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>

On Thu, Apr 10, 2014 at 3:57 PM, David Herrmann <dh.herrmann@gmail.com> wrote:
> Hi
>
> On Thu, Apr 10, 2014 at 11:16 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>> Would it make sense for the initial mode on a memfd inode to be 000?
>> Anyone who finds this to be problematic could use fchmod to fix it.
>
> memfd_create() should be subject to umask() just like anything else.
> That should solve any possible race here, right?

Yes, but how many people will actually think about umask when doing
things that don't really look like creating files?

/proc/pid/fd is a really weird corner case in which the mode of an
inode that doesn't have a name matters.  I suspect that almost no one
will ever want to open one of these things out of /proc/self/fd, and
those who do should be made to think about it.

It also avoids odd screwups where things are secure until someone runs
them with umask 000.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
