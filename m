Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C4F146B005C
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 17:14:37 -0400 (EDT)
Message-ID: <4AC12902.2040608@crca.org.au>
Date: Tue, 29 Sep 2009 07:22:10 +1000
From: Nigel Cunningham <ncunningham@crca.org.au>
MIME-Version: 1.0
Subject: Re: No more bits in vm_area_struct's vm_flags.
References: <4AB9A0D6.1090004@crca.org.au>    <20090924100518.78df6b93.kamezawa.hiroyu@jp.fujitsu.com>    <4ABC80B0.5010100@crca.org.au>    <20090925174009.79778649.kamezawa.hiroyu@jp.fujitsu.com>    <4AC0234F.2080808@crca.org.au>    <20090928120450.c2d8a4e2.kamezawa.hiroyu@jp.fujitsu.com>    <20090928033624.GA11191@localhost>    <20090928125705.6656e8c5.kamezawa.hiroyu@jp.fujitsu.com>    <Pine.LNX.4.64.0909281637160.25798@sister.anvils> <a0ea21a7cfe313202e2b51510aa5435a.squirrel@webmail-b.css.fujitsu.com> <Pine.LNX.4.64.0909282134100.11529@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0909282134100.11529@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi.

Hugh Dickins wrote:
> On Tue, 29 Sep 2009, KAMEZAWA Hiroyuki wrote:
> unsigned long long is certainly the natural choice: that way leaves
> freedom for people to add more flags in future without worrying about
> which flags variable to put them into.  I'd better explain some of my
> objections to Nigel's patch in a reply to him rather than here.

I'd prefer long long too if it's feasible. I'm just not an expert on the
issues, and so went in the direction I was pushed :) It looks a lot
cleaner and simpler to me, too, to keep everything in one variable.

Regards,

Nigel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
