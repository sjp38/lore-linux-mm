Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2E8E45F0003
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:22:32 -0400 (EDT)
Received: by wa-out-1112.google.com with SMTP id m34so23507wag.22
        for <linux-mm@kvack.org>; Wed, 03 Jun 2009 09:22:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LFD.2.01.0906030827580.4880@localhost.localdomain>
References: <20090530192829.GK6535@oblivion.subreption.com>
	 <20090530230022.GO6535@oblivion.subreption.com>
	 <alpine.LFD.2.01.0905301902010.3435@localhost.localdomain>
	 <20090531022158.GA9033@oblivion.subreption.com>
	 <alpine.DEB.1.10.0906021130410.23962@gentwo.org>
	 <20090602203405.GC6701@oblivion.subreption.com>
	 <alpine.DEB.1.10.0906031047390.15621@gentwo.org>
	 <alpine.LFD.2.01.0906030800490.4880@localhost.localdomain>
	 <alpine.DEB.1.10.0906031121030.15621@gentwo.org>
	 <alpine.LFD.2.01.0906030827580.4880@localhost.localdomain>
Date: Wed, 3 Jun 2009 12:22:16 -0400
Message-ID: <7e0fb38c0906030922u3af8c2abi8a2cfdcd66151a5a@mail.gmail.com>
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change
	ZERO_SIZE_PTR to point at unmapped space)
From: Eric Paris <eparis@parisplace.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, "Larry H." <research@subreption.com>, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

On Wed, Jun 3, 2009 at 11:38 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
>
> On Wed, 3 Jun 2009, Christoph Lameter wrote:
>
>> On Wed, 3 Jun 2009, Linus Torvalds wrote:
>>
>> > The point being that we do need to support mmap at zero. Not necessarily
>> > universally, but it can't be some fixed "we don't allow that".
>>
>> Hmmm... Depend on some capability? CAP_SYS_PTRACE may be something
>> remotely related?
>
> But as mentioned several times, we do have the system-wide setting in
> 'mmap_min_addr' (that then can be overridden by CAP_SYS_RAWIO, so in that
> sense a capability already exists).
>
> It defaults to 64kB in at least the x86 defconfig files, but to 0 in the
> Kconfig defaults. Also, for some reason it has a "depends on SECURITY",
> which means that if you just default to the old-style unix security you'll
> lose it.
>
> So there are several ways to disable it by mistake. I don't know what
> distros do.

Fedora has it on.

As I recall the only need for CONFIG_SECURITY is for the ability to
override the check.

I think I could probably pretty cleanly change it to use
CAP_SYS_RAWIO/SELinux permissions if CONFIG_SECURITY and just allow it
for uid=0 in the non-security case?  Deny it for everyone in the
non-security case and make them change the /proc tunable if they need
it?

-Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
