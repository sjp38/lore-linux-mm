Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id AAA14865
	for <linux-mm@kvack.org>; Wed, 20 Nov 2002 00:33:32 -0800 (PST)
Message-ID: <3DDB48DA.2898B7FE@digeo.com>
Date: Wed, 20 Nov 2002 00:33:30 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: Porting to from Solaris 64bit to Linux 32B - 36B.
References: <C5BF7C2C6ADF24448763CC46235FB3A691C82E@ulysses.neocore.com> <Pine.LNX.4.44L.0211192222300.4103-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Jon Goldberg <jgoldberg@neocore.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Tue, 19 Nov 2002, Jon Goldberg wrote:
> 
> >       We are currently at porting to Linux 2.4 kernel and I am having
> > troubles finding information on VM.  Since the 2.4 Kernel support large
> > amount of swap < 1TB and Physical Ram < 64GB.  Is there a way to get
> > memory functions like mmap to use a 64 bit pointer instead of the 32bit
> > pointer.  Since a memory mapped file the file is used as swap I should
> > be able to have it map a file larger than 4GB and have the OS do the
> > page management.
> 
> No, this is not possible because of fundamental reasons.
> 

I think he's asking "where is mmap64()"?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
