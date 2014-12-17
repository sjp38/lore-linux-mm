Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7C5316B0082
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 04:04:27 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id l15so15260459wiw.4
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 01:04:27 -0800 (PST)
Received: from mail-wg0-x233.google.com (mail-wg0-x233.google.com. [2a00:1450:400c:c00::233])
        by mx.google.com with ESMTPS id uv8si5535672wjc.97.2014.12.17.01.04.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Dec 2014 01:04:25 -0800 (PST)
Received: by mail-wg0-f51.google.com with SMTP id x12so19346834wgg.24
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 01:04:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141216155028.6a500d7a79eab815dbeb950e@linux-foundation.org>
References: <20141126191145.3089.90947.stgit@zurg>
	<20141216104218.GB22920@dhcp22.suse.cz>
	<20141216155028.6a500d7a79eab815dbeb950e@linux-foundation.org>
Date: Wed, 17 Dec 2014 13:04:25 +0400
Message-ID: <CALYGNiNSA1faTB_9Ngdrsv8xS7einysdMmmVeX=T-aX_RJLobg@mail.gmail.com>
Subject: Re: [PATCH v3] mm: prevent endless growth of anon_vma hierarchy
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Tim Hartrick <tim@edgecast.com>, Daniel Forrest <dan.forrest@ssec.wisc.edu>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Vlastimil Babka <vbabka@suse.cz>

On Wed, Dec 17, 2014 at 2:50 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 16 Dec 2014 11:42:18 +0100 Michal Hocko <mhocko@suse.cz> wrote:
>
>> What happened to this patch? I do not see it merged for 3.19 and
>> nor in the current mmotm tree (2014-12-15-17-05)
>>
>
> Awaiting v4.  See Konstantin's reply to Rik's review comments.
>
> Konstantin, please ensure that the questions which Rik asked are
> answered (via code comments and changelogging) in the next version?
> Because other future readers will have the same questions.
>

Done.

Thanks for reminding.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
