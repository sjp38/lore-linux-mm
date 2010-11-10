Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1ED446B004A
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 04:25:44 -0500 (EST)
Date: Wed, 10 Nov 2010 04:25:40 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1869903388.2208641289381140311.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <alpine.LSU.2.00.1011082223120.2896@sister.anvils>
Subject: Re: understand KSM
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


>  mm/ksm.c |    9 +++++++++
>  1 file changed, 9 insertions(+)
This fixed the problem for me. Thanks.

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
