Date: Tue, 1 May 2001 12:35:29 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: About reading /proc/*/mem
In-Reply-To: <m1oftdozsi.fsf@frodo.biederman.org>
Message-ID: <Pine.GSO.4.21.0105011231330.9771-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Richard F Weber <rfweber@link.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On 1 May 2001, Eric W. Biederman wrote:

> > Unfortunately, ptrace() probobally isn't going to allow me to do that.  
> > So my next question is does opening /proc/*/mem force the child process 
> > to stop on every interrupt (just like ptrace?)
> 
> 
> The not stopping the child should be the major difference between
> /proc/*/mem and ptrace.

Could somebody tell me what would one do with data read from memory
of process that is currently running?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
