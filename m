Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id LAA28041
	for <linux-mm@kvack.org>; Thu, 13 Mar 2003 11:34:48 -0800 (PST)
Date: Thu, 13 Mar 2003 11:34:48 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.64-mm6
Message-Id: <20030313113448.595c6119.akpm@digeo.com>
In-Reply-To: <1047572586.1281.1.camel@ixodes.goop.org>
References: <20030313032615.7ca491d6.akpm@digeo.com>
	<1047572586.1281.1.camel@ixodes.goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jeremy Fitzhardinge <jeremy@goop.org> wrote:
>
> On Thu, 2003-03-13 at 03:26, Andrew Morton wrote:
> >   This means that when an executable is first mapped in, the kernel will
> >   slurp the whole thing off disk in one hit.  Some IO changes were made to
> >   speed this up.
> 
> Does this just pull in text and data, or will it pull any debug sections
> too?  That could fill memory with a lot of useless junk.
> 

Just text, I expect.  Unless glibc is mapping debug info with PROT_EXEC ;)

It's just a fun hack.  Should be done in glibc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
