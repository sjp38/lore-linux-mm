Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id E393F6B0302
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 05:00:12 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id t18so2131490qtj.3
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 02:00:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j29si2455607qtl.88.2018.11.06.02.00.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 02:00:12 -0800 (PST)
Date: Tue, 6 Nov 2018 18:00:07 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH] mm, memory_hotplug: teach has_unmovable_pages about of
 LRU migrateable pages
Message-ID: <20181106100007.GN27491@MiWiFi-R3L-srv>
References: <20181105091407.GB4361@dhcp22.suse.cz>
 <20181105092851.GD4361@dhcp22.suse.cz>
 <20181105102520.GB22011@MiWiFi-R3L-srv>
 <20181105123837.GH4361@dhcp22.suse.cz>
 <20181105142308.GJ27491@MiWiFi-R3L-srv>
 <20181105171002.GO4361@dhcp22.suse.cz>
 <20181106002216.GK27491@MiWiFi-R3L-srv>
 <20181106082826.GC27423@dhcp22.suse.cz>
 <20181106091624.GL27491@MiWiFi-R3L-srv>
 <20181106095109.GJ27423@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181106095109.GJ27423@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On 11/06/18 at 10:51am, Michal Hocko wrote:
> > I just tested the movable zone checking yesterday, will add your
> > previous check back, then test again. I believe the result will be
> > positive. Will udpate once done.
> 
> THere is no need to retest with that patch for your movable node setup.

OK, thanks.
