Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DF3396B004D
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 17:25:38 -0400 (EDT)
Message-ID: <4AC12BA8.40704@crca.org.au>
Date: Tue, 29 Sep 2009 07:33:28 +1000
From: Nigel Cunningham <ncunningham@crca.org.au>
MIME-Version: 1.0
Subject: Re: No more bits in vm_area_struct's vm_flags.
References: <4AB9A0D6.1090004@crca.org.au> <20090924100518.78df6b93.kamezawa.hiroyu@jp.fujitsu.com> <4ABC80B0.5010100@crca.org.au> <20090925174009.79778649.kamezawa.hiroyu@jp.fujitsu.com> <4AC0234F.2080808@crca.org.au> <20090928120450.c2d8a4e2.kamezawa.hiroyu@jp.fujitsu.com> <20090928033624.GA11191@localhost> <20090928125705.6656e8c5.kamezawa.hiroyu@jp.fujitsu.com> <4AC03D9C.3020907@crca.org.au> <Pine.LNX.4.64.0909282200470.11529@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0909282200470.11529@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Hugh.

Hugh Dickins wrote:
> I suggested before that for the moment you reuse VM_MAPPED_COPY,
> and you said "Okee doke".  What changed?

I made a mistake - got stuck at the point where I wasn't sure that was
an option. Everything had gone quiet and I wanted to make some headway,
so I started trying to make some progress by working on the path I
knew would be doable.

Sorry about that.

Nigel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
