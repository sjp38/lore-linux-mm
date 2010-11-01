Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5E4DE8D0030
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 16:14:30 -0400 (EDT)
Date: Mon, 1 Nov 2010 16:14:20 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH] Add Kconfig option for default swappiness
Message-ID: <20101101201420.GI840@cmpxchg.org>
References: <1288548508-22070-1-git-send-email-bgamari.foss@gmail.com>
 <20101101124322.GG840@cmpxchg.org>
 <8739rlnr3l.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8739rlnr3l.fsf@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Ben Gamari <bgamari.foss@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 01, 2010 at 08:52:30AM -0400, Ben Gamari wrote:
> On Mon, 1 Nov 2010 08:43:22 -0400, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > On Sun, Oct 31, 2010 at 02:08:28PM -0400, Ben Gamari wrote:
> > > This will allow distributions to tune this important vm parameter in a more
> > > self-contained manner.
> > 
> > What's wrong with sticking
> > 
> > 	vm.swappiness = <your value>
> > 
> > into the shipped /etc/sysctl.conf?
> 
> Ubuntu ships different kernels for desktop and server usage. From a
> packaging standpoint it would be much nicer to have this set in the
> kernel configuration. If we were to throw the setting /etc/sysctl.conf
> the kernel would depend upon the package containing sysctl(8)
> (procps). We'd rather avoid this and keep the default kernel
> configuration in one place.

Fair point.  Feel free to add my

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
