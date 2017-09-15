Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 799956B0033
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 07:55:41 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id d6so5776300itc.6
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 04:55:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j131si477187oia.148.2017.09.15.04.55.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Sep 2017 04:55:39 -0700 (PDT)
Subject: Re: Detecting page cache trashing state
References: <150543458765.3781.10192373650821598320@takondra-t460s>
From: Zdenek Kabelac <zkabelac@redhat.com>
Message-ID: <20733be8-6038-434f-c50f-0a57616ebe47@redhat.com>
Date: Fri, 15 Sep 2017 13:55:37 +0200
MIME-Version: 1.0
In-Reply-To: <150543458765.3781.10192373650821598320@takondra-t460s>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Taras Kondratiuk <takondra@cisco.com>, linux-mm@kvack.org
Cc: xe-linux-external@cisco.com, Ruslan Ruslichenko <rruslich@cisco.com>, linux-kernel@vger.kernel.org

Dne 15.9.2017 v 02:16 Taras Kondratiuk napsal(a):
> Hi
> 
> In our devices under low memory conditions we often get into a trashing
> state when system spends most of the time re-reading pages of .text
> sections from a file system (squashfs in our case). Working set doesn't
> fit into available page cache, so it is expected. The issue is that
> OOM killer doesn't get triggered because there is still memory for
> reclaiming. System may stuck in this state for a quite some time and
> usually dies because of watchdogs.
> 
> We are trying to detect such trashing state early to take some
> preventive actions. It should be a pretty common issue, but for now we
> haven't find any existing VM/IO statistics that can reliably detect such
> state.
> 
> Most of metrics provide absolute values: number/rate of page faults,
> rate of IO operations, number of stolen pages, etc. For a specific
> device configuration we can determine threshold values for those
> parameters that will detect trashing state, but it is not feasible for
> hundreds of device configurations.
> 
> We are looking for some relative metric like "percent of CPU time spent
> handling major page faults". With such relative metric we could use a
> common threshold across all devices. For now we have added such metric
> to /proc/stat in our kernel, but we would like to find some mechanism
> available in upstream kernel.
> 
> Has somebody faced similar issue? How are you solving it?
> 
Hi

Well I witness this when running Firefox & Thunderbird on my desktop for a 
while on just 4G RAM machine till these 2app eat all free RAM...

It gets to the position (when I open new tab) that mouse hardly moves - 
kswapd eats  CPU  (I've no swap in fact - so likely just page-caching).

The only 'quick' solution for me as desktop user is to manually invoke OOM
with SYSRQ+F key -  and I'm also wondering why the system is not reacting 
better.  In most cases it kills one of those 2 - but sometime it kills whole 
Xsession...


Regards

Zdenek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
