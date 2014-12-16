Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 536116B0032
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 18:50:32 -0500 (EST)
Received: by mail-ig0-f180.google.com with SMTP id h15so8045254igd.1
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 15:50:32 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id be5si1157031igb.5.2014.12.16.15.50.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Dec 2014 15:50:31 -0800 (PST)
Date: Tue, 16 Dec 2014 15:50:28 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] mm: prevent endless growth of anon_vma hierarchy
Message-Id: <20141216155028.6a500d7a79eab815dbeb950e@linux-foundation.org>
In-Reply-To: <20141216104218.GB22920@dhcp22.suse.cz>
References: <20141126191145.3089.90947.stgit@zurg>
	<20141216104218.GB22920@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Tim Hartrick <tim@edgecast.com>, Daniel Forrest <dan.forrest@ssec.wisc.edu>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Vlastimil Babka <vbabka@suse.cz>

On Tue, 16 Dec 2014 11:42:18 +0100 Michal Hocko <mhocko@suse.cz> wrote:

> What happened to this patch? I do not see it merged for 3.19 and
> nor in the current mmotm tree (2014-12-15-17-05)
> 

Awaiting v4.  See Konstantin's reply to Rik's review comments.

Konstantin, please ensure that the questions which Rik asked are
answered (via code comments and changelogging) in the next version?
Because other future readers will have the same questions.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
