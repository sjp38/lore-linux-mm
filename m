Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 23CF26B004D
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 17:48:20 -0400 (EDT)
Message-ID: <4A32CD79.5040803@redhat.com>
Date: Sat, 13 Jun 2009 00:49:45 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] RFC - ksm api change into madvise
References: <1242261048-4487-1-git-send-email-ieidus@redhat.com> <Pine.LNX.4.64.0906081555360.22943@sister.anvils> <4A2D47C1.5020302@redhat.com> <Pine.LNX.4.64.0906081902520.9518@sister.anvils> <4A2D7036.1010800@redhat.com> <20090609074848.5357839a@woof.tlv.redhat.com> <Pine.LNX.4.64.0906091807300.20120@sister.anvils> <Pine.LNX.4.64.0906092013580.31606@sister.anvils> <20090610092855.43be2405@woof.tlv.redhat.com> <Pine.LNX.4.64.0906111700390.18609@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0906111700390.18609@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: aarcange@redhat.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, chrisw@redhat.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
>
> Okay.  We do have a macro to annotate such pacifying initializations,
> but I've not used it before, and forget what it is or where to look
> for an example, I don't see it in kernel.h or compiler.h.  Maybe
> Andrew will chime in and remind us.
>
> Hugh
>   
I have looked on compiler.h - this file have something that deal with 
warnings, but didnt find anything that is good for our case....

Anyone know where is this thing is found?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
