Message-ID: <4471701D.5030708@sgi.com>
Date: Mon, 22 May 2006 10:02:37 +0200
From: Jes Sorensen <jes@sgi.com>
MIME-Version: 1.0
Subject: Re: [RFC 4/5] page migration: Support moving of individual pages
References: <20060518182111.20734.5489.sendpatchset@schroedinger.engr.sgi.com>	<20060518182131.20734.27190.sendpatchset@schroedinger.engr.sgi.com>	<20060519122757.4b4767b3.akpm@osdl.org>	<Pine.LNX.4.64.0605191603110.26870@schroedinger.engr.sgi.com> <20060519164539.401a8eec.akpm@osdl.org>
In-Reply-To: <20060519164539.401a8eec.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, bls@sgi.com, lee.schermerhorn@hp.com, kamezawa.hiroyu@jp.fujitsu.com, mtk-manpages@gmx.net
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Christoph Lameter <clameter@sgi.com> wrote:
>> On Fri, 19 May 2006, Andrew Morton wrote:
>>> I expect this is going to be a bitch to write compat emulation for.  If we
>>> want to support this syscall for 32-bit userspace.
>> Page migration on a 32 bit platform? Do we really need that?
> 
> sys_migrate_pages is presently wired up in the x86 syscall table.  And it's
> available in x86_64's 32-bit mode.

And probably other architectures where the 32 bit userland is the
primary one used (Sparc64, PARISC and possibly others).


Cheers,
Jes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
