Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id OAA15290
	for <linux-mm@kvack.org>; Fri, 14 Mar 2003 14:27:02 -0800 (PST)
Date: Fri, 14 Mar 2003 14:21:39 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.64-mm6
Message-Id: <20030314142139.675c994b.akpm@digeo.com>
In-Reply-To: <3E725156.5000102@inet.com>
References: <20030313032615.7ca491d6.akpm@digeo.com>
	<3E723DBF.6040304@inet.com>
	<20030314125354.409ca02a.akpm@digeo.com>
	<3E725156.5000102@inet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eli Carter <eli.carter@inet.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Eli Carter <eli.carter@inet.com> wrote:
>
> If I can feed you changes to kgdb, would you be interested in taking 
> them?

Sure.

> What was the last patch you shipped with George's version?

Long time ago.  I'll send you the latest.

> Which do you think would be the right place to start?

George's.  It enters the debugger way earlier in boot and appears to have
stronger SMP support.  Has more features, etc.

> "We"... I like that word.  ;)  If you can act as 'upstream' for my 
> changes and answer quick questions, I'll feed you patches.

Sure.  The patches are against base 2.5.x, so your work will be separated
from -mm goings-on.

> I'm thinking I'll try to wind up with 2 or 3 patches, kgdb.patch, 
> kgdb-arm.patch, and kgdb-ia32.patch.  Maybe.

That sounds appropriate.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
