Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id BAA16615
	for <linux-mm@kvack.org>; Wed, 29 Jan 2003 01:33:34 -0800 (PST)
Date: Wed, 29 Jan 2003 01:33:54 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: Linus rollup
Message-Id: <20030129013354.03f5ee33.akpm@digeo.com>
In-Reply-To: <20030128220729.1f61edfe.akpm@digeo.com>
References: <20030128220729.1f61edfe.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: rmk@arm.linux.org.uk, ak@muc.de, davem@redhat.com, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@digeo.com> wrote:
>
> Gents,
> 
> I've sifted out all the things which I intend to send to the boss soon

Forgot to mention:

- sys_semtimedop() is only wired up for ia32/ia64 at present.

- This rollup contains the new sys_fadvise(), so unless Linus bounces
  my first syscall, that will need hooking up for non-ia32 too.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
