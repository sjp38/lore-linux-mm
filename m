Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id OAA05376
	for <linux-mm@kvack.org>; Mon, 3 Mar 2003 14:11:14 -0800 (PST)
Date: Mon, 3 Mar 2003 14:07:29 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.63-mm2
Message-Id: <20030303140729.4fa6ef5e.akpm@digeo.com>
In-Reply-To: <1046729013.30197.316.camel@dell_ss3.pdx.osdl.net>
References: <20030302180959.3c9c437a.akpm@digeo.com>
	<1046726154.30192.312.camel@dell_ss3.pdx.osdl.net>
	<20030303131734.33a95472.akpm@digeo.com>
	<1046729013.30197.316.camel@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Hemminger <shemminger@osdl.org>
Cc: linux-mm@kvack.org, Nick Piggin <piggin@cyberone.com.au>
List-ID: <linux-mm.kvack.org>

Stephen Hemminger <shemminger@osdl.org> wrote:
>
> 
> Thanks, turning off CONFIG_MODVERSIONS builds. Next problem is that
> it hangs when loading the usb module during boot up.
> This appears to be as i/o scheduler specific, because same kernel boots
> with "elevator=deadline".
> 
> Smells like another AS scheduler bug.

It does.  The elusive lost request problem.  Is it possible to make this
happen on a machine to which Nick and I can get access?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
