Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id TAA16465
	for <linux-mm@kvack.org>; Thu, 13 Mar 2003 19:51:43 -0800 (PST)
Date: Thu, 13 Mar 2003 19:51:49 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.64-mm6
Message-Id: <20030313195149.55b517c7.akpm@digeo.com>
In-Reply-To: <1047613609.2848.3.camel@localhost.localdomain>
References: <20030313032615.7ca491d6.akpm@digeo.com>
	<1047572586.1281.1.camel@ixodes.goop.org>
	<20030313113448.595c6119.akpm@digeo.com>
	<1047611104.14782.5410.camel@spc1.mesatop.com>
	<20030313192809.17301709.akpm@digeo.com>
	<1047613609.2848.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Shawn <core@enodev.com>
Cc: elenstev@mesatop.com, jeremy@goop.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Shawn <core@enodev.com> wrote:
>
> Being an active user of the 2.5 series including -mm, should I have
> updated glibc, or is there nothing new enough yet to warrant that?

I think so, yes.  There is the threading support and also the new
sysenter system-call entry code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
