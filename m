Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 09C4C6B0006
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 07:29:09 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n2-v6so5566208edr.5
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 04:29:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p21-v6si2274567edm.136.2018.07.02.04.29.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 04:29:07 -0700 (PDT)
Date: Mon, 2 Jul 2018 13:29:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: be more informative in OOM task list
Message-ID: <20180702112906.GH19043@dhcp22.suse.cz>
References: <7de14c6cac4a486c04149f37948e3a76028f3fa5.1530461087.git.rfreire@redhat.com>
 <20180702093043.GB19043@dhcp22.suse.cz>
 <1113748807.15224076.1530530533122.JavaMail.zimbra@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1113748807.15224076.1530530533122.JavaMail.zimbra@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rodrigo Freire <rfreire@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 02-07-18 07:22:13, Rodrigo Freire wrote:
> Hello Michal,
> 
> ----- Original Message ----- 
> > From: "Michal Hocko" <mhocko@kernel.org>
> > To: "Rodrigo Freire" <rfreire@redhat.com>
> > Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
> > Sent: Monday, July 2, 2018 6:30:43 AM
> > Subject: Re: [PATCH] mm: be more informative in OOM task list
> >
> > On Sun 01-07-18 13:09:40, Rodrigo Freire wrote:
> > > The default page memory unit of OOM task dump events might not be
> > > intuitive for the non-initiated when debugging OOM events. Add
> > > a small printk prior to the task dump informing that the memory
> > > units are actually memory _pages_.
> >
> > Does this really help? I understand the the oom report might be not the
> > easiest thing to grasp but wouldn't it be much better to actually add
> > documentation with clarification of each part of it?
> 
> That would be great: After a quick grep -ri for oom in Documentation,
> I found several other files containing its own OOM behaviour modifier
> configurations. But it indeed lacks a central and canonical Doc file
> which documents the OOM Killer behavior and workflows.
> 
> However, I still stand by my proposed patch: It is unobtrusive, infers
> no performance issue and clarifying: I recently worked in a case (for
> full disclosure: I am a far cry from a MM expert) where the sum of the
> RSS pages made sense when interpreted as real kB pages. Reason: There
> were processes sharing (a good amount of) memory regions, misleading
> the interpretation and that misled not only me, but some other
> colleagues a well: The pages was only sorted out after actually
> inspecting the source code.
> 
> This patch is user-friendly and can be a great time saver to others in
> the community.

Well, all other counters we print are in page units unless explicitly
kB. So I am not sure we really need to do anything but document the
output better. Maybe others will find it more important though.

-- 
Michal Hocko
SUSE Labs
