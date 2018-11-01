Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id B950D6B0010
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 05:42:52 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id c33-v6so19884448qta.20
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 02:42:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t64-v6si8475396qkd.154.2018.11.01.02.42.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 02:42:52 -0700 (PDT)
Date: Thu, 1 Nov 2018 17:42:43 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: Memory hotplug failed to offline on bare metal system of
 multiple nodes
Message-ID: <20181101094243.GD14493@MiWiFi-R3L-srv>
References: <20181101091055.GA15166@MiWiFi-R3L-srv>
 <20181101092212.GB23921@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181101092212.GB23921@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/01/18 at 10:22am, Michal Hocko wrote:
> > I haven't figured out why the above commit caused those memmory
> > block in MOVABL zone being not removable. Still checking. Attach the
> > tested reverting patch in this mail.
> 
> Could you check which of the test inside has_unmovable_pages claimed the
> failure? Going back to marking movable_zone as guaranteed to offline is
> just too fragile.

Sure, will add debugging code and check. Will update if anything found.
