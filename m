From: Andi Kleen <ak@suse.de>
Subject: Re: Extract have_task_perm() from kill and migrate functions.
Date: Mon, 22 May 2006 16:36:02 +0200
References: <Pine.LNX.4.64.0605220719310.3432@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0605220719310.3432@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200605221636.02407.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Why is this on linux-mm? Wouldn't it more for linux-kernel?

> ptrace() has a variation on the have_task_perm() check in may_attach().
> ptrace checks for uid equal to euid, suid, uid or gid equal to
> egid sgid,gid. So one may not be able to kill a process explicyly
> but be able to ptrace() (and then PTRACE_KILL it) if one is a member
> of the same group? Weird.

Sounds like a bug yes. I would suggest to switch it to the stricter
test from kill()


> 
> Plus ptrace does not support eid comparision. So explicit rights
> for ptracing cannot be set via the super user bit.

That might even have a deeper meaning. I remember there were
subtle bugs in this area long ago. But likely it is a bug too.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
