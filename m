Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id EAA03379
	for <linux-mm@kvack.org>; Fri, 28 Feb 2003 04:23:21 -0800 (PST)
Date: Fri, 28 Feb 2003 04:24:17 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.63-mm1
Message-Id: <20030228042417.38dd9e80.akpm@digeo.com>
In-Reply-To: <1046434612.4418.5.camel@lws04.home.net>
References: <20030227025900.1205425a.akpm@digeo.com>
	<1046434612.4418.5.camel@lws04.home.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: steven roemen <sdroemen1@cox.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

steven roemen <sdroemen1@cox.net> wrote:
>
> 
> the kernel oopses when i2c is compiled into the kernel with -mm1, and
> -mm1 with dave mccraken's patch.  

Please send a full report on this to the mailing list.

> also when i remove i2c from the kernel and boot into it with AS as the
> elevator, the load (via top) starts at 2.00, yet the processors aren't
> loaded very much at all.  is this a known issue(this is the first -mm
> kernel i've run)?

Run `ps aux' when the system is idle and see if there are any tasks
in "D" state.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
