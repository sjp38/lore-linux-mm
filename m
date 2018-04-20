Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E00506B0005
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 13:43:19 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id x32-v6so5349065pld.16
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 10:43:19 -0700 (PDT)
Received: from mail1.windriver.com (mail1.windriver.com. [147.11.146.13])
        by mx.google.com with ESMTPS id h3si5329670pgf.314.2018.04.20.10.43.18
        for <linux-mm@kvack.org>
        (version=TLS1_1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 20 Apr 2018 10:43:18 -0700 (PDT)
Message-ID: <5ADA26AB.6080209@windriver.com>
Date: Fri, 20 Apr 2018 11:43:07 -0600
From: Chris Friesen <chris.friesen@windriver.com>
MIME-Version: 1.0
Subject: per-NUMA memory limits in mem cgroup?
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

Hi,

I'm aware of the ability to use the memory controller to limit how much memory a 
group of tasks can consume.

Is there any way to limit how much memory a group of tasks can consume *per NUMA 
node*?

The specific scenario I'm considering is that of a hypervisor host.  I have 
system management stuff running on the host that may need more than one core, 
and currently these host tasks might be affined to cores from multiple NUMA 
nodes.  I'd like to put a cap on how much memory the host tasks can allocate 
from each NUMA node in order to ensure that there is a guaranteed amount of 
memory available for VMs on each NUMA node.

Is this possible, or are the knobs just not there?

Thanks,
Chris
