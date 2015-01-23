Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 467006B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 15:33:48 -0500 (EST)
Received: by mail-oi0-f46.google.com with SMTP id a141so8373042oig.5
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 12:33:48 -0800 (PST)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id mj1si1358784oeb.42.2015.01.23.12.33.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 23 Jan 2015 12:33:47 -0800 (PST)
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YEkvL-003UOn-EI
	for linux-mm@kvack.org; Fri, 23 Jan 2015 20:33:47 +0000
Message-ID: <54C2B01D.4070303@roeck-us.net>
Date: Fri, 23 Jan 2015 12:33:33 -0800
From: Guenter Roeck <linux@roeck-us.net>
MIME-Version: 1.0
Subject: Re: mmotm 2015-01-22-15-04: qemu failure due to 'mm: memcontrol:
 remove unnecessary soft limit tree node test'
References: <54c1822d.RtdGfWPekQVAw8Ly%akpm@linux-foundation.org> <20150123050802.GB22751@roeck-us.net> <20150123141817.GA22926@phnom.home.cmpxchg.org> <alpine.DEB.2.11.1501231419420.11767@gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1501231419420.11767@gentwo.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

On 01/23/2015 12:20 PM, Christoph Lameter wrote:
> On Fri, 23 Jan 2015, Johannes Weiner wrote:
>
>>          struct mem_cgroup_tree_per_node *rtpn;
>>          struct mem_cgroup_tree_per_zone *rtpz;
>> -       int tmp, node, zone;
>> +       int node, zone;
>>
>>          for_each_node(node) {
>
> Do for_each_online_node(node) {
>
> instead?
>

Wouldn't that have unintended consequences ? So far
rb tree nodes are allocated even if a node not online;
the above would change that. Are you saying it is
unnecessary to initialize rb tree nodes if the node
is not online ?

Not that I have any idea what is correct, it just seems odd
that the existing code would do all this allocation if it is not
necessary.

Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
