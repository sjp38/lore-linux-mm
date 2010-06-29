Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2917E6B01B2
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 07:27:54 -0400 (EDT)
Subject: Re: [PATCH] Add munmap events to perf
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100629083323.GA6917@us.ibm.com>
References: <1277748484-23882-1-git-send-email-ebmunson@us.ibm.com>
	 <1277755486.3561.140.camel@laptop>  <20100629083323.GA6917@us.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 29 Jun 2010 13:27:46 +0200
Message-ID: <1277810866.1868.32.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <ebmunson@us.ibm.com>
Cc: mingo@elte.hu, paulus@samba.org, acme@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Blanchard <anton@samba.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-06-29 at 09:33 +0100, Eric B Munson wrote:
> On Mon, 28 Jun 2010, Peter Zijlstra wrote:
>=20
> > On Mon, 2010-06-28 at 19:08 +0100, Eric B Munson wrote:
> > > This patch adds a new software event for munmaps.  It will allows
> > > users to profile changes to address space.  munmaps will be tracked
> > > with mmaps.
> >=20
> > Why?
> >=20
>=20
> It is going to be used by a tool that will model memory usage over the
> lifetime of a process.

Wouldn't it be better to use some tracepoints for that instead? I want
to keep the sideband data to a minimum required to interpret the sample
data, and you don't need unmap events for that.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
