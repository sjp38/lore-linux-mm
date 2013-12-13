Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 603176B0080
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 05:51:04 -0500 (EST)
Received: by mail-qc0-f179.google.com with SMTP id i8so1345915qcq.10
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 02:51:04 -0800 (PST)
Received: from mail-vb0-x233.google.com (mail-vb0-x233.google.com [2607:f8b0:400c:c02::233])
        by mx.google.com with ESMTPS id r6si1731059qaj.127.2013.12.13.02.51.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Dec 2013 02:51:03 -0800 (PST)
Received: by mail-vb0-f51.google.com with SMTP id 11so1143844vbe.24
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 02:51:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52AAD8D4.2060807@gmx.de>
References: <529217CD.1000204@gmx.de>
	<20131203140214.GB31128@quack.suse.cz>
	<529E3450.9000700@gmx.de>
	<20131203230058.GA24037@quack.suse.cz>
	<20131204130639.GA31973@quack.suse.cz>
	<52A36389.7010103@gmx.de>
	<20131211202639.GE1163@quack.suse.cz>
	<52AAD8D4.2060807@gmx.de>
Date: Fri, 13 Dec 2013 11:51:02 +0100
Message-ID: <CAFLxGvy16wv0m4D+ydmqbksUu9CaEaDtGdtnk1YHa56jAU+SEA@mail.gmail.com>
Subject: Re: [uml-devel] why does index in truncate_inode_pages_range() grows
 so much ?
From: Richard Weinberger <richard.weinberger@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>
Cc: Jan Kara <jack@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, UML devel <user-mode-linux-devel@lists.sourceforge.net>

On Fri, Dec 13, 2013 at 10:52 AM, Toralf F=F6rster <toralf.foerster@gmx.de>=
 wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA256
>
> On 12/11/2013 09:26 PM, Jan Kara wrote:
>> Thanks! So this works more or less as expected - trinity issued a
>> read at absurdly high offset so we created pagecache page a that
>> offset and tried to read data into it. That failed. We left the
>> page in the pagecache where it was for reclaim to reclaim it when
>> free pages are needed. Everything works as designed except we could
>> possibly argue that it's not the most efficient way to use
>> pages...
>>
>> Patch 'vfs: fix a bug when we do some dio reads with append dio
>> writes' (http://www.spinics.net/lists/linux-fsdevel/msg70899.html)
>> should actually change the situation and we won't unnecessarily
>> cache these pages.
>>
> confirmed - applied to latest git tree of Linus I helps.

Good to know! :-)

--=20
Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
