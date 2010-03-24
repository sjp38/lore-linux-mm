Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E74576B01B9
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 20:03:13 -0400 (EDT)
Received: by bwz19 with SMTP id 19so5740438bwz.6
        for <linux-mm@kvack.org>; Tue, 23 Mar 2010 17:03:11 -0700 (PDT)
Subject: Re: [Bugme-new] [Bug 15618] New: 2.6.18->2.6.32->2.6.33 huge regression in performance
Mime-Version: 1.0 (Apple Message framework v1077)
Content-Type: text/plain; charset=us-ascii
From: Anton Starikov <ant.starikov@gmail.com>
In-Reply-To: <alpine.LFD.2.00.1003231653260.18017@i5.linux-foundation.org>
Date: Wed, 24 Mar 2010 01:03:09 +0100
Content-Transfer-Encoding: quoted-printable
Message-Id: <5D95EFF7-F924-4B0D-8B05-0D85697E315D@gmail.com>
References: <bug-15618-10286@https.bugzilla.kernel.org/> <20100323102208.512c16cc.akpm@linux-foundation.org> <20100323173409.GA24845@elte.hu> <alpine.LFD.2.00.1003231037410.18017@i5.linux-foundation.org> <9D040E9A-80F2-468F-A6CD-A4912615CD3F@gmail.com> <alpine.LFD.2.00.1003231253570.18017@i5.linux-foundation.org> <9FC34DA1-D6DD-41E5-8B76-0712A813C549@gmail.com> <alpine.LFD.2.00.1003231602130.18017@i5.linux-foundation.org> <20100323233640.GA16798@elte.hu> <alpine.LFD.2.00.1003231653260.18017@i5.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Greg KH <greg@kroah.com>, stable@kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Yes, it is included into my list.
When I will submit it into stable, I will include it also.

Anton

On Mar 24, 2010, at 12:55 AM, Linus Torvalds wrote:

>=20
>=20
> On Wed, 24 Mar 2010, Ingo Molnar wrote:
>>=20
>> We havent had any stability problems with them, except one trivial =
build bug,=20
>> so -stable would be nice.
>=20
> Oh, you're right. There was that UML build bug. But I think that was=20=

> included in the list of commits Anton had - commit 4126faf0ab ("x86: =
Fix=20
> breakage of UML from the changes in the rwsem system").
>=20
> 		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
