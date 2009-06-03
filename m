Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0CA5B5F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:32:08 -0400 (EDT)
Received: by wf-out-1314.google.com with SMTP id 25so48244wfa.11
        for <linux-mm@kvack.org>; Wed, 03 Jun 2009 09:32:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LFD.2.01.0906030925480.4880@localhost.localdomain>
References: <20090530192829.GK6535@oblivion.subreption.com>
	 <20090531022158.GA9033@oblivion.subreption.com>
	 <alpine.DEB.1.10.0906021130410.23962@gentwo.org>
	 <20090602203405.GC6701@oblivion.subreption.com>
	 <alpine.DEB.1.10.0906031047390.15621@gentwo.org>
	 <alpine.LFD.2.01.0906030800490.4880@localhost.localdomain>
	 <alpine.DEB.1.10.0906031121030.15621@gentwo.org>
	 <alpine.LFD.2.01.0906030827580.4880@localhost.localdomain>
	 <7e0fb38c0906030922u3af8c2abi8a2cfdcd66151a5a@mail.gmail.com>
	 <alpine.LFD.2.01.0906030925480.4880@localhost.localdomain>
Date: Wed, 3 Jun 2009 12:32:07 -0400
Message-ID: <7e0fb38c0906030932o28d5c963y8059672e5c2c7ecf@mail.gmail.com>
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change
	ZERO_SIZE_PTR to point at unmapped space)
From: Eric Paris <eparis@parisplace.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, "Larry H." <research@subreption.com>, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

On Wed, Jun 3, 2009 at 12:28 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
>
> On Wed, 3 Jun 2009, Eric Paris wrote:
>>
>> As I recall the only need for CONFIG_SECURITY is for the ability to
>> override the check.
>
> No, if you have SECURITY disabled entirely, the check goes away.

I meant 'need' as in the reason I wrapped it in CONFIG_SECURITY, not
that you were wrong when you said it disapeared.

>> I think I could probably pretty cleanly change it to use
>> CAP_SYS_RAWIO/SELinux permissions if CONFIG_SECURITY and just allow it
>> for uid=0 in the non-security case?
>
> We probably should, since the "capability" security version should
> generally essentially emulate the regular non-SECURITY case for root.

Will poke/patch this afternoon.

-Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
