Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id AF991900014
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 16:01:44 -0500 (EST)
Received: by mail-qg0-f48.google.com with SMTP id q108so7912801qgd.35
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 13:01:44 -0800 (PST)
Received: from mx6-phx2.redhat.com (mx6-phx2.redhat.com. [209.132.183.39])
        by mx.google.com with ESMTPS id 33si14093006qgf.64.2014.11.11.13.01.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Nov 2014 13:01:43 -0800 (PST)
Date: Tue, 11 Nov 2014 16:01:00 -0500 (EST)
From: David Airlie <airlied@redhat.com>
Message-ID: <1169847148.8603193.1415739660148.JavaMail.zimbra@redhat.com>
In-Reply-To: <20141111095903.GH10501@worktop.programming.kicks-ass.net>
References: <1415644096-3513-1-git-send-email-j.glisse@gmail.com> <CA+55aFwHd4QYopHvd=H6hxoQeqDV3HT6=436LGU-FRb5A0p7Vg@mail.gmail.com> <20141110205814.GA4186@gmail.com> <CA+55aFwwKV_D5oWT6a97a70G7OnvsPD_j9LsuR+_e4MEdCOO9A@mail.gmail.com> <20141110225036.GB4186@gmail.com> <CA+55aFyfgj5ntoXEJeTZyGdOZ9_A_TK0fwt1px_FUhemXGgr0Q@mail.gmail.com> <20141111024531.GA2503@gmail.com> <20141111095903.GH10501@worktop.programming.kicks-ass.net>
Subject: Re: [PATCH 3/5] lib: lockless generic and arch independent page
 table (gpt) v2.
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jerome Glisse <j.glisse@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Joerg Roedel <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>


> On Mon, Nov 10, 2014 at 09:45:33PM -0500, Jerome Glisse wrote:
> > All the complexity arise from two things, first the need to keep ad-hoc
> > link btw directory level to facilitate iteration over range.
> 
> btw means "by the way" not "between", use a dictionary some time.
> 

Thanks for the in-depth review Peter.

Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
