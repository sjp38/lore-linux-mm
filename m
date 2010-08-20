Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 53B006B02B9
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 19:12:42 -0400 (EDT)
Date: Fri, 20 Aug 2010 18:12:38 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [S+Q Cleanup4 0/6] SLUB: Cleanups V4
In-Reply-To: <alpine.DEB.2.00.1008201405080.4202@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1008201810450.8436@router.home>
References: <20100820173711.136529149@linux.com> <alpine.DEB.2.00.1008201405080.4202@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 20 Aug 2010, David Rientjes wrote:

> > Remove static allocation of kmem_cache_cpu array and rely on the
> > percpu allocator to allocate memory for the array on bootup.
> >
>
> I don't see this patch in the v4 posting of your series.

I see it on the list. So I guess just wait until it reaches you.

Return-path: <owner-linux-mm@kvack.org>
Envelope-to: cl@localhost
Delivery-date: Fri, 20 Aug 2010 18:06:17 -0500
Received: from localhost ([127.0.0.1] helo=router.home)
    by router.home with esmtp (Exim 4.71)
    (envelope-from <owner-linux-mm@kvack.org>)
    id 1OmafA-0002Aj-Td
    for cl@localhost; Fri, 20 Aug 2010 18:06:17 -0500
Received: from imap1.linux-foundation.org [140.211.169.55]
    by router.home with IMAP (fetchmail-6.3.9-rc2)
    for <cl@localhost> (single-drop); Fri, 20 Aug 2010 18:06:16 -0500
(CDT)
Received: from smtp1.linux-foundation.org (smtp1.linux-foundation.org
    [140.211.169.13])
    by imap1.linux-foundation.org
(8.13.5.20060308/8.13.5/Debian-3ubuntu1.1)
     with ESMTP id o7KN2jWM011206;
    Fri, 20 Aug 2010 16:02:45 -0700
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
    by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with
    ESMTP id o7KN29PM008217;
    Fri, 20 Aug 2010 16:02:10 -0700
Received: by kanga.kvack.org (Postfix)
    id BA5636006BA; Fri, 20 Aug 2010 19:02:06 -0400 (EDT)
Delivered-To: linux-mm-outgoing@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 0)
    id B872D6004CE; Fri, 20 Aug 2010 19:02:06 -0400 (EDT)
X-Original-To: int-list-linux-mm@kvack.org
Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
    id 8D1896004CE; Fri, 20 Aug 2010 19:02:06 -0400 (EDT)
X-Original-To: linux-mm@kvack.org
Delivered-To: linux-mm@kvack.org
Received: from mail203.messagelabs.com (mail203.messagelabs.com
    [216.82.254.243])
    by kanga.kvack.org (Postfix) with SMTP id 1E8B96004CE
    for <linux-mm@kvack.org>; Fri, 20 Aug 2010 19:02:06 -0400 (EDT)
X-VirusChecked: Checked
X-Env-Sender: cl@linux.com
X-Msg-Ref: server-13.tower-203.messagelabs.com!1282345324!71922773!1
X-StarScan-Version: 6.2.4; banners=-,-,-
X-Originating-IP: [76.13.13.45]
X-SpamReason: No, hits=0.0 required=7.0 tests=UNPARSEABLE_RELAY
Received: (qmail 24791 invoked from network); 20 Aug 2010 23:02:05 -0000
Received: from smtp106.prem.mail.ac4.yahoo.com (HELO
    smtp106.prem.mail.ac4.yahoo.com) (76.13.13.45)
  by server-13.tower-203.messagelabs.com with SMTP; 20 Aug 2010 23:02:05
    -0000

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
