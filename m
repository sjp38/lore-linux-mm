Subject: Re: 2.5.64-mm6
From: Robert Love <rml@tech9.net>
In-Reply-To: <1047613609.2848.3.camel@localhost.localdomain>
References: <20030313032615.7ca491d6.akpm@digeo.com>
	 <1047572586.1281.1.camel@ixodes.goop.org>
	 <20030313113448.595c6119.akpm@digeo.com>
	 <1047611104.14782.5410.camel@spc1.mesatop.com>
	 <20030313192809.17301709.akpm@digeo.com>
	 <1047613609.2848.3.camel@localhost.localdomain>
Content-Type: text/plain
Message-Id: <1047614200.1226.28.camel@icbm>
Mime-Version: 1.0
Date: 13 Mar 2003 22:56:41 -0500
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Shawn <core@enodev.com>
Cc: Andrew Morton <akpm@digeo.com>, Steven Cole <elenstev@mesatop.com>, jeremy@goop.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2003-03-13 at 22:46, Shawn wrote:

> This reminds me of something I've not looked into for some time.
> 
> Being an active user of the 2.5 series including -mm, should I have
> updated glibc, or is there nothing new enough yet to warrant that?

In 2.3 and beyond (current is 2.3.2 I think), there are a few 2.5
changes.  Nothing required, though.

The biggest is NPTL, which takes advantage of all the threading stuff.

There is also sysenter support.

And support for new 2.5 system calls - most, but not all, of them are
there.  I know the affinity calls are.  And the new posix_fadvise().

> Maybe I should just ask the glibc people. Wasn't sure what the proper
> forum was.

libc-alpha is the public glibc list.  It is hosted at
sources.redhat.com.

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
