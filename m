Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 775718D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 18:45:19 -0400 (EDT)
From: Sean Noonan <Sean.Noonan@twosigma.com>
Date: Tue, 29 Mar 2011 18:45:15 -0400
Subject: RE: XFS memory allocation deadlock in 2.6.38
Message-ID: <081DDE43F61F3D43929A181B477DCA95639B5361@MSXAOA6.twosigma.com>
References: <081DDE43F61F3D43929A181B477DCA95639B5327@MSXAOA6.twosigma.com>
 <20110324174311.GA31576@infradead.org>
 <AANLkTikwwRm6FHFtEdUg54NvmKdswQw-NPH5dtq1mXBK@mail.gmail.com>
 <081DDE43F61F3D43929A181B477DCA95639B5349@MSXAOA6.twosigma.com>
 <BANLkTin0jJevStg5P2hqsLbqMzo3o30sYg@mail.gmail.com>
 <081DDE43F61F3D43929A181B477DCA95639B534E@MSXAOA6.twosigma.com>
 <081DDE43F61F3D43929A181B477DCA95639B5359@MSXAOA6.twosigma.com>
 <20110329192434.GA10536@infradead.org>
 <081DDE43F61F3D43929A181B477DCA95639B535C@MSXAOA6.twosigma.com>
 <20110329200256.GA6019@infradead.org> <20110329224230.GH3008@dastard>
In-Reply-To: <20110329224230.GH3008@dastard>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Dave Chinner' <david@fromorbit.com>, 'Christoph Hellwig' <hch@infradead.org>
Cc: Trammell Hudson <Trammell.Hudson@twosigma.com>, Christos Zoulas <Christos.Zoulas@twosigma.com>, Martin Bligh <Martin.Bligh@twosigma.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, Stephen Degler <Stephen.Degler@twosigma.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-xfs@oss.sgi.com'" <linux-xfs@oss.sgi.com>, 'Michel Lespinasse' <walken@google.com>

> Need to keep the if (!irbuf) check as KM_MAYFAIL is passed.

It wasn't in before the bug presented, so leaving it in wouldn't be a true =
test as to whether the bug has been tracked to the correct place.  I'll tes=
t again with the if (!irbuf).

Sean

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
