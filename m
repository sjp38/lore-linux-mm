Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 255D96B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 16:44:28 -0500 (EST)
Received: by pablf10 with SMTP id lf10so8298485pab.12
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 13:44:27 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id oa11si13212945pdb.33.2015.02.25.13.44.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Feb 2015 13:44:27 -0800 (PST)
Date: Wed, 25 Feb 2015 13:44:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: hide per-cpu lists in output of show_mem()
Message-Id: <20150225134426.d907ecb7130d12dc8ad97c90@linux-foundation.org>
In-Reply-To: <CALYGNiO8Y3oJbPMF8m2ndtBp5=RBiw3o6rKyWsGXF0RyT9JYVQ@mail.gmail.com>
References: <20150220143942.19568.4548.stgit@buzz>
	<20150223143746.GG24272@dhcp22.suse.cz>
	<CALYGNiO8Y3oJbPMF8m2ndtBp5=RBiw3o6rKyWsGXF0RyT9JYVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, 24 Feb 2015 13:03:01 +0400 Konstantin Khlebnikov <koct9i@gmail.com> wrote:

> On Mon, Feb 23, 2015 at 5:37 PM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Fri 20-02-15 17:39:42, Konstantin Khlebnikov wrote:
> >> This makes show_mem() much less verbose at huge machines. Instead of
> >> huge and almost useless dump of counters for each per-zone per-cpu
> >> lists this patch prints sum of these counters for each zone (free_pcp)
> >> and size of per-cpu list for current cpu (local_pcp).
> >
> > I like this! I do not remember when I found this information useful
> > while debugging either an allocation failure warning or OOM killer
> > report.
> >
> >> Flag SHOW_MEM_PERCPU_LISTS reverts old verbose mode.
> >
> > Nobody seems to be using this flag so why bother?
> 
> Yes. But this might be important for architectures which has asymmetrical
> memory topology, I've heard about unicorns like that.

Please provide more details about this (why important?  How would it
be used) and I'll add it to the changelog.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
