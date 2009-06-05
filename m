Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C9F0E6B004D
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 00:40:43 -0400 (EDT)
Subject: Re: [PATCH] - support inheritance of mlocks across fork/exec V2
From: Jon Masters <jonathan@jonmasters.org>
In-Reply-To: <1228331069.6693.73.camel@lts-notebook>
References: <1227561707.6937.61.camel@lts-notebook>
	 <20081125152651.b4c3c18f.akpm@linux-foundation.org>
	 <1228331069.6693.73.camel@lts-notebook>
Content-Type: text/plain
Date: Fri, 05 Jun 2009 00:39:17 -0400
Message-Id: <1244176757.11597.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, hugh@veritas.com, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wed, 2008-12-03 at 14:04 -0500, Lee Schermerhorn wrote:

> Add support for mlockall(MCL_INHERIT|MCL_RECURSIVE):

FWIW, I really liked this patch series. And I think there is still value
in a generic "mlock" wrapper utility that I can use. Sure, the later on
containers suggestions are all wonderful in theory but I don't see that
that went anywhere either (and I disagree that we can't trust people to
use this right without doing silly things) - if I'm really right that
this got dropped on the floor, can we resurrect it in .31 please?

Jon.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
