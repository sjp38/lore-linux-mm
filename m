Date: Mon, 19 Mar 2001 20:42:45 -0700 (MST)
From: Ronald G Minnich <rminnich@lanl.gov>
Subject: Re: 2.4.2 kernel weirdness
In-Reply-To: <m3d7bdmkp7.fsf@DLT.linuxnetworx.com>
Message-ID: <Pine.LNX.4.30.0103192040380.666-100000@white.acl.lanl.gov>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederman@lnxi.com>
Cc: Andrew Stanley-Jones <asj@amphus.com>, linux-mm@kvack.org, LinuxBIOS <linuxbios@lanl.gov>, Jim Bailey <jbailey@amphus.com>
List-ID: <linux-mm.kvack.org>

On 19 Mar 2001, Eric W. Biederman wrote:

> Andrew Stanley-Jones <asj@amphus.com> writes:
>
> > I wasn't confident of the SDRAM setup on an embedded 486 machine, so I
> > wrote a user space program to write and read mem to make sure everything
> > was ok.  Well when the program runs almost instantly it generates a oops
> > (with eip in schedual).  Assuming SDRAM setup was bad I added various
> > checks in boot up to read and write mem.  They didn't show any problems,
> > I can read and write all I like, the mem works.

I think your memory is misconfigured. This problem looks suspiciously like
you only really have about 8M actually working, i.e. you're saying you
have 64m but you're getting address line wrap such that you're trashing
low kernel memory. This can happen with a misconfigured north bridge. That
might explain why falling over the 4M boundary is killing you. Not sure
though.

ron

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
