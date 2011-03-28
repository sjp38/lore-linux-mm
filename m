Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1875E8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 17:06:35 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p2SL6Wa2009636
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 14:06:32 -0700
Received: from qwf6 (qwf6.prod.google.com [10.241.194.70])
	by hpaq7.eem.corp.google.com with ESMTP id p2SL6QZ1009772
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 14:06:31 -0700
Received: by qwf6 with SMTP id 6so2880134qwf.2
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 14:06:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <081DDE43F61F3D43929A181B477DCA95639B5349@MSXAOA6.twosigma.com>
References: <081DDE43F61F3D43929A181B477DCA95639B52FD@MSXAOA6.twosigma.com>
	<081DDE43F61F3D43929A181B477DCA95639B5327@MSXAOA6.twosigma.com>
	<20110324174311.GA31576@infradead.org>
	<AANLkTikwwRm6FHFtEdUg54NvmKdswQw-NPH5dtq1mXBK@mail.gmail.com>
	<081DDE43F61F3D43929A181B477DCA95639B5349@MSXAOA6.twosigma.com>
Date: Mon, 28 Mar 2011 14:06:25 -0700
Message-ID: <BANLkTin0jJevStg5P2hqsLbqMzo3o30sYg@mail.gmail.com>
Subject: Re: XFS memory allocation deadlock in 2.6.38
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sean Noonan <Sean.Noonan@twosigma.com>
Cc: Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Martin Bligh <Martin.Bligh@twosigma.com>, Trammell Hudson <Trammell.Hudson@twosigma.com>, Christos Zoulas <Christos.Zoulas@twosigma.com>, "linux-xfs@oss.sgi.com" <linux-xfs@oss.sgi.com>, Stephen Degler <Stephen.Degler@twosigma.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Mar 28, 2011 at 7:58 AM, Sean Noonan <Sean.Noonan@twosigma.com> wrote:
>> Regarding the deadlock: I am curious to see if it could be made to
>> happen before 5ecfda041e4b4bd858d25bbf5a16c2a6c06d7272. Could you test
>> what happens if you remove the MAP_POPULATE flag from your mmap call,
>> and instead read all pages from userspace right after the mmap ? I
>> expect you would then be able to trigger the deadlock before
>> 5ecfda041e4b4bd858d25bbf5a16c2a6c06d7272.
>
> I still see the deadlock without MAP_POPULATE

Could you test if you see the deadlock before
5ecfda041e4b4bd858d25bbf5a16c2a6c06d7272 without MAP_POPULATE ?

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
