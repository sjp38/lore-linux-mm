Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id 721736B0035
	for <linux-mm@kvack.org>; Wed,  4 Jun 2014 12:03:34 -0400 (EDT)
Received: by mail-we0-f175.google.com with SMTP id p10so8856540wes.34
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 09:03:33 -0700 (PDT)
Received: from mail.emea.novell.com (mail.emea.novell.com. [130.57.118.101])
        by mx.google.com with ESMTPS id gj1si5643855wjd.74.2014.06.04.09.03.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 04 Jun 2014 09:03:32 -0700 (PDT)
Message-Id: <538F5F720200007800017E73@mail.emea.novell.com>
Date: Wed, 04 Jun 2014 17:03:30 +0100
From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [PATCH] improve __GFP_COLD/__GFP_ZERO interaction
References: <538CAA520200007800016E87@mail.emea.novell.com>
 <538C9E3F.3000403@citrix.com>
In-Reply-To: <538C9E3F.3000403@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: mingo@elte.hu, linux-mm@kvack.org, tglx@linutronix.de, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, hpa@zytor.com

>>> On 02.06.14 at 17:54, <david.vrabel@citrix.com> wrote:
> On 02/06/14 15:46, Jan Beulich wrote:
>>=20
>> --- 3.15-rc8/drivers/xen/balloon.c
>> +++ 3.15-rc8-clear-cold-highpage/drivers/xen/balloon.c
>=20
> Please split the Xen part out into a separate patch since this is a
> useful cleanup either way.

Actually I'm not convinced the Xen part alone is a good change: By
switching to __GFP_COLD allocations without using suitable special
cased memory scrubbing you'd blow good parts of your data cache
for no good reason, i.e. this quite likely would introduce a
performance regression. Which I wouldn't want to put my name
under.

Jan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
