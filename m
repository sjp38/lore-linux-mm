Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3CE036B0271
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 07:38:48 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x21-v6so11131790eds.2
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 04:38:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o90-v6si7134345edb.241.2018.07.16.04.38.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 04:38:46 -0700 (PDT)
Date: Mon, 16 Jul 2018 13:38:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Bug report about KASLR and ZONE_MOVABLE
Message-ID: <20180716113845.GM17280@dhcp22.suse.cz>
References: <20180711094244.GA2019@localhost.localdomain>
 <20180711104158.GE2070@MiWiFi-R3L-srv>
 <20180711104944.GG1969@MiWiFi-R3L-srv>
 <20180711124008.GF2070@MiWiFi-R3L-srv>
 <72721138-ba6a-32c9-3489-f2060f40a4c9@cn.fujitsu.com>
 <20180712060115.GD6742@localhost.localdomain>
 <20180712123228.GK32648@dhcp22.suse.cz>
 <20180712235240.GH2070@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180712235240.GH2070@MiWiFi-R3L-srv>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: Chao Fan <fanc.fnst@cn.fujitsu.com>, Dou Liyang <douly.fnst@cn.fujitsu.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, yasu.isimatu@gmail.com, keescook@chromium.org, indou.takao@jp.fujitsu.com, caoj.fnst@cn.fujitsu.com, vbabka@suse.cz, mgorman@techsingularity.net

On Fri 13-07-18 07:52:40, Baoquan He wrote:
> Hi Michal,
> 
> On 07/12/18 at 02:32pm, Michal Hocko wrote:
[...]
> > I am not able to find the beginning of the email thread right now. Could
> > you summarize what is the actual problem please?
> 
> The bug is found on x86 now. 
> 
> When added "kernelcore=" or "movablecore=" into kernel command line,
> kernel memory is spread evenly among nodes. However, this is right when
> KASLR is not enabled, then kernel will be at 16M of place in x86 arch.
> If KASLR enabled, it could be put any place from 16M to 64T randomly.
>  
> Consider a scenario, we have 10 nodes, and each node has 20G memory, and
> we specify "kernelcore=50%", means each node will take 10G for
> kernelcore, 10G for movable area. But this doesn't take kernel position
> into consideration. E.g if kernel is put at 15G of 2nd node, namely
> node1. Then we think on node1 there's 10G for kernelcore, 10G for
> movable, in fact there's only 5G available for movable, just after
> kernel.

OK, I guess I see that part. But who is going to use movablecore along
with KASLR enabled? I mean do we really have to support those two
obscure command line parameters for KASLR?

In fact I would be much more concerned about memory hotplug and
pre-defined movable nodes. Does the current KASLR code work in that
case?
-- 
Michal Hocko
SUSE Labs
