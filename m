Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2DEF66B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 15:02:28 -0400 (EDT)
Date: Tue, 31 Mar 2009 21:02:14 +0200
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: Detailed Stack Information Patch [0/3]
Message-ID: <20090331190214.GB25879@logfs.org>
References: <1238511498.364.60.camel@matrix> <87eiwdn15a.fsf@basil.nowhere.org> <1238523735.3692.30.camel@matrix>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1238523735.3692.30.camel@matrix>
Sender: owner-linux-mm@kvack.org
To: Stefani Seibold <stefani@seibold.net>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 31 March 2009 20:22:15 +0200, Stefani Seibold wrote:
> Am Dienstag, den 31.03.2009, 17:49 +0200 schrieb Andi Kleen:
> > Stefani Seibold <stefani@seibold.net> writes:
> 
> > > - Misuse the thread stack for big temporary data buffers
> > 
> > That would be better checked for at compile time
> > (except for alloca, but that is quite rare)
> 
> Fine but it did not work for functions like:
> 
> void foo(int n)
> {
> 	char buf[n*1024];
> 
> }
> 
> This is valid with gcc.

Good call.  checkstack should look for those as well.  It is certainly
possible to detect statically and warn about:

  10:   29 c4                   sub    %eax,%esp

Runaway recursions are a different matter, though.  The code I once had
to detect them depends on an old version of smatch, which in turn
depends on gcc 3.1.  And even assuming this was in a reasonable shape, I
still don't know what to do about it.  The kernel has thousands of
recursions and trying to work out how deep each one may stack is a
never-ending project.

JA?rn

-- 
A quarrel is quickly settled when deserted by one party; there is
no battle unless there be two.
-- Seneca

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
