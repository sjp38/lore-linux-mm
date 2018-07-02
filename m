Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id A4D786B0003
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 07:22:15 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id o3-v6so12050007otl.16
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 04:22:15 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g22-v6si311487ote.339.2018.07.02.04.22.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 04:22:14 -0700 (PDT)
Date: Mon, 2 Jul 2018 07:22:13 -0400 (EDT)
From: Rodrigo Freire <rfreire@redhat.com>
Message-ID: <1113748807.15224076.1530530533122.JavaMail.zimbra@redhat.com>
In-Reply-To: <20180702093043.GB19043@dhcp22.suse.cz>
References: <7de14c6cac4a486c04149f37948e3a76028f3fa5.1530461087.git.rfreire@redhat.com> <20180702093043.GB19043@dhcp22.suse.cz>
Subject: Re: [PATCH] mm: be more informative in OOM task list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello Michal,

----- Original Message ----- 
> From: "Michal Hocko" <mhocko@kernel.org>
> To: "Rodrigo Freire" <rfreire@redhat.com>
> Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
> Sent: Monday, July 2, 2018 6:30:43 AM
> Subject: Re: [PATCH] mm: be more informative in OOM task list
>
> On Sun 01-07-18 13:09:40, Rodrigo Freire wrote:
> > The default page memory unit of OOM task dump events might not be
> > intuitive for the non-initiated when debugging OOM events. Add
> > a small printk prior to the task dump informing that the memory
> > units are actually memory _pages_.
>
> Does this really help? I understand the the oom report might be not the
> easiest thing to grasp but wouldn't it be much better to actually add
> documentation with clarification of each part of it?

That would be great: After a quick grep -ri for oom in Documentation,
I found several other files containing its own OOM behaviour modifier
configurations. But it indeed lacks a central and canonical Doc file
which documents the OOM Killer behavior and workflows.

However, I still stand by my proposed patch: It is unobtrusive, infers
no performance issue and clarifying: I recently worked in a case (for
full disclosure: I am a far cry from a MM expert) where the sum of the
RSS pages made sense when interpreted as real kB pages. Reason: There
were processes sharing (a good amount of) memory regions, misleading
the interpretation and that misled not only me, but some other
colleagues a well: The pages was only sorted out after actually
inspecting the source code.

This patch is user-friendly and can be a great time saver to others in
the community.

I kindly request the ACKed-by ;-)

Have a great week,

- RF.
