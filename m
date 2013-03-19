Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id DFA956B00B1
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 21:44:43 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1UKIwi-0007OC-Db
	for linux-mm@kvack.org; Tue, 26 Mar 2013 02:45:04 +0100
Received: from 173-164-30-65-Nashville.hfc.comcastbusiness.net ([173.164.30.65])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 26 Mar 2013 02:45:04 +0100
Received: from wad by 173-164-30-65-Nashville.hfc.comcastbusiness.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 26 Mar 2013 02:45:04 +0100
From: Will Drewry <wad@chromium.org>
Subject: Re: security: restricting access to swap
Date: Tue, 19 Mar 2013 17:39:44 +0000 (UTC)
Message-ID: <loom.20130319T153437-176@post.gmane.org>
References: <CAA25o9RchY2AD8U30bh4H+fz6kq8bs98SUrkJUkTpbTHSGjcGA@mail.gmail.com> <5147A68B.9030207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

KOSAKI Motohiro <kosaki.motohiro <at> gmail.com> writes:

> 
> (3/11/13 7:57 PM), Luigi Semenzato wrote:
> > Greetings linux-mmers,
> > 
> > before we can fully deploy zram, we must ensure it conforms to the
> > Chrome OS security requirements.  In particular, we do not want to
> > allow user space to read/write the swap device---not even root-owned
> > processes.
> 
> Could you explain Chrome OS security requirement at first? We don't want
> to guess your requirement.

I'll try to add a little more flavor. We're continuing to reduce the
exposure from root-equivalent users wherever possible.  Enabling swap
support to a block device means an alternative means to access/modify
swapped out user-context  memory with a single discretionary access
control check, bypassing any per-process checks in /proc/<pid>/mem
(like mm_open(..., PTRACE_MODE_ATTACH)), and so on.

hth!
will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
