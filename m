Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id LAA09198
	for <linux-mm@kvack.org>; Tue, 25 Feb 2003 11:11:47 -0800 (PST)
Date: Tue, 25 Feb 2003 11:12:15 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.62-mm3 -Panics during dbt2 run
Message-Id: <20030225111215.27c14ac7.akpm@digeo.com>
In-Reply-To: <200302251849.h1PInh921599@mail.osdl.org>
References: <20030225015537.4062825b.akpm@digeo.com>
	<200302251849.h1PInh921599@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Cliff White <cliffw@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dmccr@us.ibm.com
List-ID: <linux-mm.kvack.org>

Cliff White <cliffw@osdl.org> wrote:
>
> 
> Tried hard to test this, but all it does for me is panic.
> Is this fixed in 2.5.63?
> This is 4-way PIII system. 
>  panic, while booting
> Press Y within 1 seconds to force file system integrity check...
>  [<c02409e8>] as_next_request+0x38/0x50

We have some rough edges in the anticipatory scheduler.  Please
boot with elevator=deadline for now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
