Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 2EBF76B0008
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 23:32:00 -0500 (EST)
Received: by mail-ie0-f180.google.com with SMTP id bn7so8741497ieb.25
        for <linux-mm@kvack.org>; Tue, 05 Mar 2013 20:31:59 -0800 (PST)
Date: Tue, 5 Mar 2013 20:31:16 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/7] ksm: treat unstable nid like in stable tree
In-Reply-To: <51369BB9.6030608@gmail.com>
Message-ID: <alpine.LNX.2.00.1303052024570.29433@eggly.anvils>
References: <alpine.LNX.2.00.1302210013120.17843@eggly.anvils> <alpine.LNX.2.00.1302210019390.17843@eggly.anvils> <51271A7D.6020305@gmail.com> <alpine.LNX.2.00.1302221250440.6100@eggly.anvils> <51303CAB.3080406@gmail.com> <alpine.LNX.2.00.1303011139270.7398@eggly.anvils>
 <51315174.4020200@gmail.com> <alpine.LNX.2.00.1303011833490.23290@eggly.anvils> <51369BB9.6030608@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Huck <will.huckk@gmail.com>
Cc: Ric Mason <ric.masonn@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 6 Mar 2013, Will Huck wrote:
> 
> How ksm treat a ksm forked page? IIUC, it's not merged in ksm stable tree. It
> will just be ignore?

No, it's there in the stable tree, as it was before it got forked.  And
when ksmd comes around to find the new mm, it will allocate an rmap_item
for that page in the new mm, and append it to the existing stable_node.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
